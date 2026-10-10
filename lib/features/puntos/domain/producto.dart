/// Producto de la comunidad que se puede comprar con descuento usando
/// puntos (por ejemplo, un polo bordado o miel de algarrobo).
class Producto {
  Producto({
    required this.id,
    required this.nombre,
    required this.puntosRequeridos,
    required this.porcentajeDescuento,
  }) {
    if (puntosRequeridos <= 0) {
      throw ArgumentError.value(
        puntosRequeridos,
        'puntosRequeridos',
        'Debe ser mayor que cero',
      );
    }
    if (porcentajeDescuento <= 0 || porcentajeDescuento > 100) {
      throw ArgumentError.value(
        porcentajeDescuento,
        'porcentajeDescuento',
        'Debe estar entre 1 y 100',
      );
    }
  }

  final String id;
  final String nombre;
  final int puntosRequeridos;
  final int porcentajeDescuento;
}
