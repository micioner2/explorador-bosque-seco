import 'reserva.dart';

/// Reservas de la asociación.
abstract interface class ReservasRepository {
  /// Reservas desde [hoy] en adelante, más las pendientes de días
  /// anteriores (grupos que no llegaron).
  List<Reserva> reservas(DateTime hoy);
}
