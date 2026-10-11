import 'coordenada.dart';
import 'ruta.dart';

/// Contrato de acceso a la ruta del espacio.
///
/// La implementación final leerá el trazado (GeoJSON) del paquete
/// descargado en el celular para que funcione sin señal.
abstract interface class RutaRepository {
  /// Ruta del espacio (El Angolo).
  Ruta rutaActual();

  /// Ruta corta alrededor de la sede de la presentación, para mostrar el
  /// GPS sobre la ruta sin ir al bosque. Se arma alrededor de [centro] (el
  /// que se tomó con el GPS en el lugar) o, si no hay, del que trae la app.
  Ruta rutaDeLaSede([Coordenada? centro]);
}
