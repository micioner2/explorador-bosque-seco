import 'escaneo.dart';
import 'producto.dart';

/// Resultado de intentar registrar un escaneo en el pasaporte.
sealed class ResultadoRegistro {
  const ResultadoRegistro();
}

/// El punto era nuevo para esta visita: se ganó un punto.
final class PuntoGanado extends ResultadoRegistro {
  const PuntoGanado(this.pasaporte);

  final Pasaporte pasaporte;
}

/// El punto ya se había escaneado en esta visita: no suma de nuevo.
final class PuntoYaRegistrado extends ResultadoRegistro {
  const PuntoYaRegistrado();
}

/// Error al canjear puntos por un producto.
class CanjeInvalido implements Exception {
  const CanjeInvalido(this.mensaje);

  final String mensaje;

  @override
  String toString() => 'CanjeInvalido: $mensaje';
}

/// Pasaporte del turista: sellos (escaneos) y puntos canjeables.
///
/// Es inmutable: cada operación devuelve un pasaporte nuevo. Reglas:
/// - Cada punto turístico da 1 punto por visita, sin importar cuántas
///   veces se escanee.
/// - Solo los puntos confirmados (sincronizados) se pueden canjear.
class Pasaporte {
  Pasaporte({Iterable<Escaneo> escaneos = const [], this.puntosCanjeados = 0})
    : escaneos = List.unmodifiable(escaneos) {
    if (puntosCanjeados < 0) {
      throw ArgumentError.value(puntosCanjeados, 'puntosCanjeados');
    }
  }

  final List<Escaneo> escaneos;
  final int puntosCanjeados;

  /// Escaneos únicos por visita y punto (el primero que se registró).
  List<Escaneo> get sellos {
    final vistos = <String>{};
    return [
      for (final escaneo in escaneos)
        if (vistos.add(escaneo.clave)) escaneo,
    ];
  }

  int get puntosConfirmados =>
      sellos.where((escaneo) => escaneo.estaConfirmado).length;

  int get puntosPendientes =>
      sellos.where((escaneo) => !escaneo.estaConfirmado).length;

  /// Puntos que se pueden usar ahora en un canje.
  int get puntosDisponibles => puntosConfirmados - puntosCanjeados;

  bool yaVisito({required String visitaId, required String puntoId}) =>
      escaneos.any((e) => e.visitaId == visitaId && e.puntoId == puntoId);

  ResultadoRegistro registrar(Escaneo escaneo) {
    if (yaVisito(visitaId: escaneo.visitaId, puntoId: escaneo.puntoId)) {
      return const PuntoYaRegistrado();
    }
    return PuntoGanado(
      Pasaporte(
        escaneos: [...escaneos, escaneo],
        puntosCanjeados: puntosCanjeados,
      ),
    );
  }

  /// Marca como confirmados los escaneos que el servidor aceptó.
  Pasaporte confirmar(Set<String> idsConfirmados) => Pasaporte(
    escaneos: [
      for (final escaneo in escaneos)
        idsConfirmados.contains(escaneo.id) ? escaneo.confirmar() : escaneo,
    ],
    puntosCanjeados: puntosCanjeados,
  );

  bool puedeCanjear(Producto producto) =>
      puntosDisponibles >= producto.puntosRequeridos;

  int puntosFaltantes(Producto producto) {
    final faltan = producto.puntosRequeridos - puntosDisponibles;
    return faltan > 0 ? faltan : 0;
  }

  Pasaporte canjear(Producto producto) {
    if (!puedeCanjear(producto)) {
      throw CanjeInvalido(
        'Faltan ${puntosFaltantes(producto)} puntos para ${producto.nombre}',
      );
    }
    return Pasaporte(
      escaneos: escaneos,
      puntosCanjeados: puntosCanjeados + producto.puntosRequeridos,
    );
  }
}
