import 'ruta.dart';

/// Contrato de acceso a la ruta del espacio.
///
/// La implementación final leerá el trazado (GeoJSON) del paquete
/// descargado en el celular para que funcione sin señal.
abstract interface class RutaRepository {
  Ruta rutaActual();
}
