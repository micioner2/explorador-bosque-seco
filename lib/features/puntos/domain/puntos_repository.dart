import 'pasaporte.dart';
import 'producto.dart';

/// Contrato de acceso al pasaporte del turista y a los productos canjeables.
///
/// El pasaporte vive en el celular: los escaneos se guardan pendientes y se
/// confirman al sincronizar cuando vuelve la señal.
abstract interface class PuntosRepository {
  Pasaporte pasaporte();

  /// Guarda el pasaporte completo (escaneos y puntos canjeados).
  Future<void> guardar(Pasaporte pasaporte);

  List<Producto> productos();
}
