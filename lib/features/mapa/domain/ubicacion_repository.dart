import 'coordenada.dart';

/// Por qué no se sabe dónde está el turista.
enum ProblemaUbicacion {
  /// El GPS del celular está apagado.
  gpsApagado,

  /// La persona no dio permiso de ubicación a la app.
  sinPermiso,
}

/// El GPS no está disponible; la pantalla explica cómo arreglarlo.
class UbicacionNoDisponible implements Exception {
  const UbicacionNoDisponible(this.problema);

  final ProblemaUbicacion problema;
}

/// Posición del turista por GPS. El GPS no necesita señal de celular:
/// funciona en el bosque, en modo avión.
abstract interface class UbicacionRepository {
  /// Posiciones a medida que el turista camina. Termina con
  /// [UbicacionNoDisponible] si el GPS está apagado o sin permiso.
  Stream<Coordenada> posiciones();
}
