/// Punto de una ruta, en el orden en que se recorre. Su [id] es el mismo
/// del QR que el turista escanea en ese lugar.
class PuntoRuta {
  PuntoRuta({
    required this.id,
    required this.nombre,
    this.metrosDesdeAnterior = 0,
    this.minutosDesdeAnterior = 0,
  }) {
    if (metrosDesdeAnterior < 0) {
      throw ArgumentError.value(
        metrosDesdeAnterior,
        'metrosDesdeAnterior',
        'No puede ser negativa',
      );
    }
    if (minutosDesdeAnterior < 0) {
      throw ArgumentError.value(
        minutosDesdeAnterior,
        'minutosDesdeAnterior',
        'No puede ser negativo',
      );
    }
  }

  final String id;
  final String nombre;

  /// Distancia a pie desde el punto anterior (0 en el inicio de la ruta).
  final int metrosDesdeAnterior;

  /// Tiempo aproximado de caminata desde el punto anterior.
  final int minutosDesdeAnterior;

  Duration get duracionDesdeAnterior => Duration(minutes: minutosDesdeAnterior);
}

/// Circuito de un espacio: lista ordenada de puntos con sus distancias.
class Ruta {
  Ruta({
    required this.id,
    required this.nombre,
    required Iterable<PuntoRuta> puntos,
  }) : puntos = List.unmodifiable(puntos) {
    if (this.puntos.isEmpty) {
      throw ArgumentError.value(puntos, 'puntos', 'Mínimo un punto');
    }
    final ids = {for (final punto in this.puntos) punto.id};
    if (ids.length != this.puntos.length) {
      throw ArgumentError.value(puntos, 'puntos', 'Hay puntos repetidos');
    }
  }

  final String id;
  final String nombre;
  final List<PuntoRuta> puntos;

  int get metrosTotales =>
      puntos.fold(0, (total, punto) => total + punto.metrosDesdeAnterior);

  Duration get duracionTotal => Duration(
    minutes: puntos.fold(
      0,
      (total, punto) => total + punto.minutosDesdeAnterior,
    ),
  );
}
