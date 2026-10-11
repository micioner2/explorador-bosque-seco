import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../reservas/domain/reserva.dart';
import '../../../reservas/presentation/view_models/reservas_view_model.dart';
import '../../domain/visita.dart';
import 'visitas_view_model.dart';

/// Grupo que el encargado está armando en el formulario, antes de
/// registrarlo. Es inmutable: cada cambio devuelve una copia nueva.
class BorradorGrupo {
  const BorradorGrupo({
    this.integrantes = const [],
    this.actividades = const {},
    this.reservaId,
  });

  /// Personas ya agregadas. La primera es la responsable del grupo.
  final List<Visitante> integrantes;

  /// Actividades que hará todo el grupo.
  final Set<Actividad> actividades;

  /// Reserva del grupo, si llegó con una. Al registrar, se convierte en su
  /// ingreso.
  final String? reservaId;

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
      reservaId: state.reservaId,
    );
  }

  void quitarIntegrante(Visitante integrante) {
    state = BorradorGrupo(
      integrantes: [
        for (final actual in state.integrantes)
          if (!identical(actual, integrante)) actual,
      ],
      actividades: state.actividades,
      reservaId: state.reservaId,
    );
  }

  /// Marca la actividad si no estaba elegida, o la desmarca si ya lo estaba.
  void alternarActividad(Actividad actividad) {
    final actividades = {...state.actividades};
    if (!actividades.remove(actividad)) actividades.add(actividad);
    state = BorradorGrupo(
      integrantes: state.integrantes,
      actividades: actividades,
      reservaId: state.reservaId,
    );
  }

  /// Llegó el grupo de una reserva: lo que se registre quedará como su
  /// ingreso. Lo ya escrito en el formulario se conserva.
  void atenderReserva(String reservaId) => state = BorradorGrupo(
    integrantes: state.integrantes,
    actividades: state.actividades,
    reservaId: reservaId,
  );

  /// El grupo se registra sin reserva.
  void soltarReserva() => state = BorradorGrupo(
    integrantes: state.integrantes,
    actividades: state.actividades,
  );

  /// Registra al grupo como una sola visita, con un único QR, y deja el
  /// formulario vacío para el siguiente grupo. Si llegó con una reserva
  /// pendiente, la reserva queda como ingreso de esta visita (R15).
  ///
  /// Lanza [ArgumentError] si falta un integrante o una actividad; en ese
  /// caso el borrador se conserva.
  Visita registrar() {
    final reservas = ref.read(reservasViewModelProvider.notifier);
    final reservaId = state.reservaId;
    // Si mientras tanto la cancelaron o ya ingresó, va sin reserva.
    final reserva = switch (reservaId == null
        ? null
        : reservas.buscar(reservaId)) {
      final Reserva r when r.pendiente => r,
      _ => null,
    };
    final visita = ref
        .read(visitasViewModelProvider.notifier)
        .registrar(
          integrantes: state.integrantes,
          actividades: state.actividades,
          reservaId: reserva?.id,
        );
    if (reserva != null) reservas.registrarIngreso(reserva.id, visita.id);
    state = const BorradorGrupo();
    return visita;
  }
}

final registroGrupoViewModelProvider =
    NotifierProvider<RegistroGrupoViewModel, BorradorGrupo>(
      RegistroGrupoViewModel.new,
    );

/// Reserva cuyo grupo se está registrando. Si mientras tanto la cancelaron
/// o ya ingresó, es `null` y el grupo se registra sin ella.
final reservaEnAtencionProvider = Provider<Reserva?>((ref) {
  final id = ref.watch(
    registroGrupoViewModelProvider.select((b) => b.reservaId),
  );
  if (id == null) return null;
  final reserva = ref.watch(
    reservasViewModelProvider.select(
      (reservas) => reservas.where((r) => r.id == id).firstOrNull,
    ),
  );
  return (reserva != null && reserva.pendiente) ? reserva : null;
});
