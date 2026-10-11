import '../../puntos/domain/escaneo.dart';
import 'coordenada.dart';
import 'ruta.dart';

/// Estado de un punto de la ruta para el turista.
enum EstadoPunto {
  /// Aún no se escaneó su QR.
  porVisitar,

  /// Escaneado sin señal: el sello espera sincronizarse.
  pendiente,

  /// Escaneado y aceptado por el servidor.
  confirmado,
}

/// Un punto de la ruta con su orden y su estado.
class PuntoEnRuta {
  const PuntoEnRuta({
    required this.orden,
    required this.punto,
    required this.estado,
  });

  /// Posición en la ruta, empezando en 1.
  final int orden;
  final PuntoRuta punto;
  final EstadoPunto estado;

  bool get visitado => estado != EstadoPunto.porVisitar;
}

/// Avance del turista en una ruta, calculado con los sellos de su pasaporte.
///
/// Reglas:
/// - Un punto cuenta como visitado si tiene al menos un sello, y queda
///   confirmado cuando alguno de esos sellos ya se sincronizó.
/// - El siguiente punto es el primero sin sello en el orden de la ruta.
class ProgresoRuta {
  const ProgresoRuta._({required this.ruta, required this.puntos});

  factory ProgresoRuta.calcular(Ruta ruta, Iterable<Escaneo> sellos) {
    final estados = <String, EstadoPunto>{};
    for (final sello in sellos) {
      if (sello.estaConfirmado) {
        estados[sello.puntoId] = EstadoPunto.confirmado;
      } else {
        estados.putIfAbsent(sello.puntoId, () => EstadoPunto.pendiente);
      }
    }
    return ProgresoRuta._(
      ruta: ruta,
      puntos: List.unmodifiable([
        for (final (indice, punto) in ruta.puntos.indexed)
          PuntoEnRuta(
            orden: indice + 1,
            punto: punto,
            estado: estados[punto.id] ?? EstadoPunto.porVisitar,
          ),
      ]),
    );
  }

  final Ruta ruta;
  final List<PuntoEnRuta> puntos;

  int get total => puntos.length;

  int get visitados => puntos.where((punto) => punto.visitado).length;

  bool get completada => visitados == total;

  /// Primer punto sin sello. Es `null` cuando la ruta está completa.
  PuntoEnRuta? get siguiente {
    for (final punto in puntos) {
      if (!punto.visitado) return punto;
    }
    return null;
  }

  /// Más lejos que esto de todos los puntos, el turista no está en la ruta
  /// (por ejemplo, aún en la ciudad): el mapa lo dice en vez de medir.
  static const metrosFueraDeRuta = 3000;

  /// Metros en línea recta desde [posicion] (GPS) hasta el siguiente punto.
  /// `null` si la ruta está completa o ese punto no tiene ubicación.
  int? metrosAlSiguiente(Coordenada posicion) =>
      siguiente?.punto.ubicacion?.distanciaA(posicion);

  /// El turista está a más de [metrosFueraDeRuta] de todos los puntos.
  bool fueraDeRuta(Coordenada posicion) {
    final ubicaciones = [for (final p in puntos) ?p.punto.ubicacion];
    if (ubicaciones.isEmpty) return false;
    return ubicaciones.every(
      (ubicacion) => ubicacion.distanciaA(posicion) > metrosFueraDeRuta,
    );
  }
}
