import 'espacio.dart';

/// Contrato de acceso a los espacios turísticos.
///
/// La implementación final leerá el paquete descargado en el celular
/// (base de datos local) para que funcione sin señal.
abstract interface class EspacioRepository {
  Espacio espacioActual();
}
