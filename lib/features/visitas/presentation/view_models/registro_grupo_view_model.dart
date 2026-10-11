import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/reloj.dart';
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
    this.salidaPrevista,
  });

  /// Personas ya agregadas. La primera es la responsable del grupo.
  final List<Visitante> integrantes;

  /// Actividades que hará todo el grupo.
  final Set<Actividad> actividades;

  /// Reserva del grupo, si llegó con una. Al registrar, se convierte en su
  /// ingreso.
  final String? reservaId;

  /// Salida elegida por el guía (si acampan, otro día). `null` = la de
  /// siempre: [Visita.duracionPorDefecto] después de entrar.
  final DateTime? salidaPrevista;

  BorradorGrupo copiar({
    List<Visitante>? integrantes,
    Set<Actividad>? actividades,
    DateTime? salidaPrevista,
  }) => BorradorGrupo(
    integrantes: integrantes ?? this.integrantes,
    actividades: actividades ?? this.actividades,
    reservaId: reservaId,
    salidaPrevista: salidaPrevista ?? this.salidaPrevista,
  );

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
    required String documento,
    required int edad,
    required Procedencia procedencia,
    String? pais,
  }) {
    final integrante = Visitante(
      nombre: nombre,
      documento: documento,
      edad: edad,
      procedencia: procedencia,
      pais: pais,
    );
    state = state.copiar(integrantes: [...state.integrantes, integrante]);
  }

  void quitarIntegrante(Visitante integrante) {
    state = state.copiar(
      integrantes: [
        for (final actual in state.integrantes)
          if (!identical(actual, integrante)) actual,
      ],
    );
  }

  /// Marca la actividad si no estaba elegida, o la desmarca si ya lo estaba.
  void alternarActividad(Actividad actividad) {
    final actividades = {...state.actividades};
    if (!actividades.remove(actividad)) actividades.add(actividad);
    state = state.copiar(actividades: actividades);
  }

  /// El grupo saldrá en otra fecha u hora (por ejemplo, si acampa).
  void elegirSalida(DateTime salida) =>
      state = state.copiar(salidaPrevista: salida);

  /// Llegó el grupo de una reserva: lo que se registre quedará como su
  /// ingreso. Lo ya escrito en el formulario se conserva.
  void atenderReserva(String reservaId) => state = BorradorGrupo(
    integrantes: state.integrantes,
    actividades: state.actividades,
    reservaId: reservaId,
    salidaPrevista: state.salidaPrevista,
  );

  /// El grupo se registra sin reserva.
  void soltarReserva() => state = BorradorGrupo(
    integrantes: state.integrantes,
    actividades: state.actividades,
    salidaPrevista: state.salidaPrevista,
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
          salidaPrevista: state.salidaPrevista,
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

/// Salida prevista que se muestra en el formulario: la elegida o, si no se
/// eligió, la de siempre a partir de ahora.
final salidaPrevistaProvider = Provider<DateTime>(
  (ref) =>
      ref.watch(
        registroGrupoViewModelProvider.select((b) => b.salidaPrevista),
      ) ??
      ref.watch(relojProvider)().add(Visita.duracionPorDefecto),
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
