import 'reserva.dart';

/// Reservas de la asociación, guardadas en el celular.
abstract interface class ReservasRepository {
  /// Reservas desde [hoy] en adelante, más las pendientes de días
  /// anteriores (grupos que no llegaron).
  List<Reserva> reservas(DateTime hoy);

  /// Guarda la reserva nueva o su cambio (reprogramada, cancelada o
  /// ingresada), por id.
  Future<void> guardar(Reserva reserva);
}
