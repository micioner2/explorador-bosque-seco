import 'dart:typed_data';

/// Cartel con un QR de la app: un punto de la ruta o el grupo de prueba.
class CartelQr {
  const CartelQr({
    required this.titulo,
    required this.detalle,
    required this.texto,
    required this.codigo,
  });

  /// Nombre del punto ("Mirador") o "Grupo de prueba".
  final String titulo;

  /// Orden en la ruta o para qué sirve.
  final String detalle;

  /// Contenido del QR (formato de `LecturaQr`).
  final String texto;

  /// Código para escribir a mano si la cámara no lee.
  final String codigo;
}

/// Arma un PDF con un cartel por página para imprimir o compartir.
abstract interface class GeneradorCarteles {
  Future<Uint8List> generar(List<CartelQr> carteles, {required String nota});
}
