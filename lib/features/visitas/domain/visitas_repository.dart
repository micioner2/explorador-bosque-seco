import 'visita.dart';

/// Contrato de acceso a las visitas registradas en el puesto de control.
///
/// La fuente de verdad es el celular: lo registrado sobrevive al cerrar la
/// app y no necesita señal.
abstract interface class VisitasRepository {
  /// Visitas que entraron el día de [dia].
  List<Visita> visitasDelDia(DateTime dia);

  /// Guarda la visita nueva o su cambio (por ejemplo, la salida), por id.
  Future<void> guardar(Visita visita);
}
