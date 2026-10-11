import 'cuenta_asociacion.dart';

/// Resultado de intentar entrar con la cuenta de la asociación.
sealed class ResultadoAcceso {
  const ResultadoAcceso();
}

/// El servidor aceptó la cuenta. Ya quedó guardada en el celular.
final class AccesoConcedido extends ResultadoAcceso {
  const AccesoConcedido(this.cuenta);

  final CuentaAsociacion cuenta;
}

/// No se pudo entrar. [motivo] dice qué mostrar a la persona.
final class AccesoDenegado extends ResultadoAcceso {
  const AccesoDenegado(this.motivo, {this.codigo});

  final MotivoRechazo motivo;

  /// Código del servidor, para diagnosticar errores inesperados.
  final String? codigo;
}

enum MotivoRechazo {
  /// El correo o la contraseña no coinciden.
  credencialesIncorrectas,

  /// La cuenta existe, pero no está ligada a una asociación activa (o no
  /// fue confirmada). Lo resuelve el administrador desde el portal.
  cuentaNoHabilitada,

  /// No se pudo llegar al servidor: sin señal o tardó demasiado.
  sinConexion,

  /// El servidor bloqueó los intentos por un rato.
  demasiadosIntentos,

  /// El servidor respondió con un error inesperado.
  errorDelServidor,
}
