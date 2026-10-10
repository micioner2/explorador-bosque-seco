import 'pasaporte.dart';
import 'producto.dart';

/// Contrato de acceso al pasaporte del turista y a los productos canjeables.
///
/// La implementación final guardará los escaneos en la base local y los
/// sincronizará con el servidor al volver la señal.
abstract interface class PuntosRepository {
  Pasaporte pasaporte();

  List<Producto> productos();
}
