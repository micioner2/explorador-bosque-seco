import 'coordenada.dart';

/// Punto de una ruta, en el orden en que se recorre. Su [id] es el mismo
/// del QR que el turista escanea en ese lugar.
class PuntoRuta {
  PuntoRuta({
    required this.id,
    required this.nombre,
    this.metrosDesdeAnterior = 0,
    this.minutosDesdeAnterior = 0,
    this.ubicacion,
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

  /// Dónde está el cartel con su QR. `null` si aún no se tomó con GPS.
  final Coordenada? ubicacion;

  Duration get duracionDesdeAnterior => Duration(minutes: minutosDesdeAnterior);
}

/// Circuito de un espacio: lista ordenada de puntos con sus distancias.
class Ruta {
  Ruta({
    required this.id,
    required this.nombre,
    required Iterable<PuntoRuta> puntos,
    Iterable<Coordenada> trazado = const [],
  }) : puntos = List.unmodifiable(puntos),
       trazado = List.unmodifiable(trazado) {
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

  /// Camino a pie, de inicio a fin, para dibujarlo en el mapa. Si no se
  /// tomó con GPS, el mapa une los puntos en línea recta.
  final List<Coordenada> trazado;

  /// La ruta se puede dibujar en un mapa: todos sus puntos tienen ubicación.
  bool get georreferenciada => puntos.every((p) => p.ubicacion != null);

  /// Líneas a dibujar: el [trazado] o, si no hay, los puntos en orden.
  List<Coordenada> get camino => trazado.isNotEmpty
      ? trazado
      : [for (final punto in puntos) ?punto.ubicacion];

  int get metrosTotales =>
      puntos.fold(0, (total, punto) => total + punto.metrosDesdeAnterior);

  Duration get duracionTotal => Duration(
    minutes: puntos.fold(
      0,
      (total, punto) => total + punto.minutosDesdeAnterior,
    ),
  );
}
