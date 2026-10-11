import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/visita.dart';
import 'visitas_view_model.dart';

/// Grupo que el encargado está armando en el formulario, antes de
/// registrarlo. Es inmutable: cada cambio devuelve una copia nueva.
class BorradorGrupo {
  const BorradorGrupo({
    this.integrantes = const [],
    this.actividades = const {},
  });

  /// Personas ya agregadas. La primera es la responsable del grupo.
  final List<Visitante> integrantes;

  /// Actividades que hará todo el grupo.
  final Set<Actividad> actividades;

  /// Ya se puede registrar: tiene al menos un integrante y una actividad.
  bool get completo => integrantes.isNotEmpty && actividades.isNotEmpty;
}

/// Estado y acciones del registro de un grupo desde una sola pantalla.
class RegistroGrupoViewModel extends Notifier<BorradorGrupo> {
  @override
  BorradorGrupo build() => const BorradorGrupo();

  /// Suma una persona al grupo. Lanza [ArgumentError] si sus datos no son
  /// válidos (las reglas viven en [Visitante]).
  void agregarIntegrante({
    required String nombre,
    required int edad,
    required Procedencia procedencia,
  }) {
    final integrante = Visitante(
      nombre: nombre,
      edad: edad,
      procedencia: procedencia,
    );
    state = BorradorGrupo(
      integrantes: [...state.integrantes, integrante],
      actividades: state.actividades,
    );
  }

  void quitarIntegrante(Visitante integrante) {
    state = BorradorGrupo(
      integrantes: [
        for (final actual in state.integrantes)
          if (!identical(actual, integrante)) actual,
      ],
      actividades: state.actividades,
    );
  }

  /// Marca la actividad si no estaba elegida, o la desmarca si ya lo estaba.
  void alternarActividad(Actividad actividad) {
    final actividades = {...state.actividades};
    if (!actividades.remove(actividad)) actividades.add(actividad);
    state = BorradorGrupo(
      integrantes: state.integrantes,
      actividades: actividades,
    );
  }

  /// Registra al grupo como una sola visita, con un único QR, y deja el
  /// formulario vacío para el siguiente grupo. Lanza [ArgumentError] si
  /// falta un integrante o una actividad; en ese caso el borrador se conserva.
  Visita registrar() {
    final visita = ref
        .read(visitasViewModelProvider.notifier)
        .registrar(
          integrantes: state.integrantes,
          actividades: state.actividades,
        );
    state = const BorradorGrupo();
    return visita;
  }
}

final registroGrupoViewModelProvider =
    NotifierProvider<RegistroGrupoViewModel, BorradorGrupo>(
      RegistroGrupoViewModel.new,
    );
