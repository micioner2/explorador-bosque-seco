/// Resultado de probar la conexión con el servidor.
sealed class EstadoConexion {
  const EstadoConexion();
}

/// La app se compiló sin servidor: funciona con los datos del celular.
final class SinConfigurar extends EstadoConexion {
  const SinConfigurar();
}

/// El servidor respondió y aceptó la clave de la app.
final class Conectado extends EstadoConexion {
  const Conectado({required this.esquemaListo});

  /// Ya existen las tablas de la app. Si es `false`, el servidor funciona
  /// pero falta crear el esquema de la base de datos.
  final bool esquemaListo;
}

/// El servidor respondió, pero rechazó la clave de la app.
final class ClaveRechazada extends EstadoConexion {
  const ClaveRechazada();
}

/// No se pudo llegar al servidor: sin señal, sin internet o tardó demasiado.
final class SinConexion extends EstadoConexion {
  const SinConexion();
}

/// El servidor respondió con un error inesperado.
final class ErrorServidor extends EstadoConexion {
  const ErrorServidor(this.codigo);

  /// Código que devolvió el servidor (por ejemplo, `500`).
  final String codigo;
}
