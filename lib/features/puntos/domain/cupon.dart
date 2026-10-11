/// Cupón de descuento que el turista obtiene al canjear sus puntos. Lo
/// muestra como QR en la tienda de la comunidad, que lo valida en el puesto
/// de control sin señal (A5).
class Cupon {
  Cupon({
    required this.id,
    required this.productoId,
    required this.nombreProducto,
    required this.porcentajeDescuento,
    required this.emitido,
  }) {
    if (porcentajeDescuento <= 0 || porcentajeDescuento > 100) {
      throw ArgumentError.value(
        porcentajeDescuento,
        'porcentajeDescuento',
        'Debe estar entre 1 y 100',
      );
    }
  }

  /// Id generado en el celular del turista (UUID).
  final String id;
  final String productoId;
  final String nombreProducto;
  final int porcentajeDescuento;
  final DateTime emitido;

  /// Texto del QR: `bosqueseco:cupon:<id>:<producto>:<porcentaje>`. Lleva
  /// lo necesario para validarlo en la tienda sin señal.
  String get codigoQr =>
      'bosqueseco:cupon:$id:$productoId:$porcentajeDescuento';
}

/// Resultado de validar un cupón en el puesto de control.
sealed class ValidacionCupon {
  const ValidacionCupon();
}

/// Primera vez que se presenta: se aplica el descuento y queda usado.
final class CuponValido extends ValidacionCupon {
  const CuponValido({required this.productoId, required this.porcentaje});

  final String productoId;
  final int porcentaje;
}

/// Ya se usó en este puesto: no se vuelve a aplicar (regla R18).
final class CuponYaUsado extends ValidacionCupon {
  const CuponYaUsado();
}

/// Cupones que el puesto de control ya aceptó.
class CuponesUsados {
  CuponesUsados([Iterable<String> ids = const []])
    : ids = Set.unmodifiable(ids);

  final Set<String> ids;

  /// Regla R18: un cupón vale una sola vez.
  ValidacionCupon validar({
    required String id,
    required String productoId,
    required int porcentaje,
  }) => ids.contains(id)
      ? const CuponYaUsado()
      : CuponValido(productoId: productoId, porcentaje: porcentaje);

  CuponesUsados usar(String id) => CuponesUsados({...ids, id});
}

/// Cupones del turista y cupones usados en el puesto, guardados en el
/// celular.
abstract interface class CuponesRepository {
  List<Cupon> cupones();

  Future<void> guardarCupones(List<Cupon> cupones);

  Set<String> usados();

  Future<void> guardarUsados(Set<String> ids);
}
