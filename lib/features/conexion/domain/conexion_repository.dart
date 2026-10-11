import 'estado_conexion.dart';

/// Contrato para probar la conexión con el servidor. Nunca lanza
/// excepciones: cada falla se devuelve como un [EstadoConexion].
abstract interface class ConexionRepository {
  Future<EstadoConexion> verificar();
}
