import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/id.dart';
import '../../../../core/reloj.dart';
import '../../../sesion/presentation/view_models/sesion_view_model.dart';
import '../../data/reservas_repository_demo.dart';
import '../../domain/agenda_reservas.dart';
import '../../domain/reserva.dart';

/// Estado y acciones de las reservas del puesto de control.
class ReservasViewModel extends Notifier<List<Reserva>> {
  DateTime get _ahora => ref.read(relojProvider)();

  @override
  List<Reserva> build() {
    final hoy = ref.watch(relojProvider)();
    return ref.watch(reservasRepositoryProvider).reservas(hoy);
  }

  /// Anota una reserva a nombre de la asociación y del guía de la sesión.
  /// Lanza [ArgumentError] si los datos no son válidos (las reglas viven en
  /// [Reserva]) y [StateError] si no hay guía elegido.
  Reserva crear({
    required String nombreContacto,
    String? telefono,
    required DateTime fechaHora,
    required int personas,
  }) {
    final (:cuenta, :guia) = ref.read(sesionViewModelProvider).quienRegistra();
    final reserva = Reserva.nueva(
      id: nuevoId(),
      asociacionId: cuenta.asociacionId,
      nombreContacto: nombreContacto,
      telefono: telefono,
      fechaHora: fechaHora,
      personas: personas,
      ahora: _ahora,
      guiaId: guia.id,
      nombreGuia: guia.nombre,
    );
    state = [...state, reserva];
    return reserva;
  }

  Reserva reprogramar(
    String id, {
    required DateTime fechaHora,
    required int personas,
  }) => _cambiar(
    id,
    (reserva) => reserva.reprogramar(
      fechaHora: fechaHora,
      personas: personas,
      ahora: _ahora,
    ),
  );

  Reserva cancelar(String id) => _cambiar(id, (reserva) => reserva.cancelar());

  /// El grupo de la reserva llegó y quedó registrado como [visitaId].
  Reserva registrarIngreso(String id, String visitaId) =>
      _cambiar(id, (reserva) => reserva.registrarIngreso(visitaId));

  Reserva? buscar(String id) => state.where((r) => r.id == id).firstOrNull;

  /// Aplica [cambio] a la reserva [id]. Las reglas del cambio viven en
  /// [Reserva]: si falla, el estado queda igual.
  Reserva _cambiar(String id, Reserva Function(Reserva) cambio) {
    final actual = buscar(id);
    if (actual == null) {
      throw ArgumentError.value(id, 'id', 'No existe esa reserva');
    }
    final nueva = cambio(actual);
    state = [for (final reserva in state) reserva.id == id ? nueva : reserva];
    return nueva;
  }
}

final reservasViewModelProvider =
    NotifierProvider<ReservasViewModel, List<Reserva>>(ReservasViewModel.new);

/// Agenda derivada para las pantallas "Hoy" y "Reservas".
final agendaReservasProvider = Provider<AgendaReservas>(
  (ref) => AgendaReservas.calcular(
    ref.watch(reservasViewModelProvider),
    ref.watch(relojProvider)(),
  ),
);
