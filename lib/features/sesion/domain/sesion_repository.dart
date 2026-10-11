import 'cuenta_asociacion.dart';
import 'resultado_acceso.dart';

/// Acceso de la asociación al modo puesto de control.
///
/// Solo [iniciarSesion] necesita señal. La cuenta queda guardada en el
/// celular y [cuentaGuardada] la lee sin conectarse, para que los guías
/// trabajen donde no hay internet.
abstract interface class SesionRepository {
  /// Cuenta con la que se entró en este celular, o `null` si hay que entrar.
  CuentaAsociacion? cuentaGuardada();

  /// Verifica el correo y la contraseña con el servidor y, si son válidos,
  /// guarda la cuenta en el celular. Nunca lanza excepciones.
  Future<ResultadoAcceso> iniciarSesion({
    required String correo,
    required String clave,
  });

  /// Borra la cuenta del celular. Funciona sin señal.
  Future<void> cerrarSesion();
}
