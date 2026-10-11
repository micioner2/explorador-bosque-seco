import 'cuenta_asociacion.dart';
import 'guia.dart';

/// Quién usa el modo puesto de control: la cuenta de la asociación (queda
/// guardada en el celular) y el guía que eligió su nombre.
///
/// Reglas R11 y R12: sin cuenta no se entra al puesto de control, y sin
/// guía no se registran visitas.
class Sesion {
  const Sesion({this.cuenta, this.guia});

  final CuentaAsociacion? cuenta;

  /// Guía que está registrando. Se vuelve a elegir cada vez que se abre la
  /// app, porque varios guías pueden compartir el mismo celular.
  final Guia? guia;

  bool get iniciada => cuenta != null;

  /// Hay cuenta y guía: ya se pueden registrar visitas.
  bool get listaParaRegistrar => cuenta != null && guia != null;

  /// Sesión con el guía elegido. Solo puede elegirse un guía de la misma
  /// asociación de la cuenta.
  Sesion elegirGuia(Guia guia) {
    final cuenta = this.cuenta;
    if (cuenta == null) {
      throw StateError('Primero hay que entrar con la cuenta de la asociación');
    }
    if (guia.asociacionId != cuenta.asociacionId) {
      throw ArgumentError.value(
        guia.id,
        'guia',
        'No pertenece a la asociación de la cuenta',
      );
    }
    return Sesion(cuenta: cuenta, guia: guia);
  }

  /// Deja la cuenta abierta para que otro guía elija su nombre.
  Sesion soltarGuia() => Sesion(cuenta: cuenta);

  /// Asociación y guía a cuyo nombre queda un registro. Lanza [StateError]
  /// si falta alguno de los dos.
  ({CuentaAsociacion cuenta, Guia guia}) quienRegistra() {
    final cuenta = this.cuenta;
    final guia = this.guia;
    if (cuenta == null || guia == null) {
      throw StateError('Para registrar hace falta la cuenta y un guía');
    }
    return (cuenta: cuenta, guia: guia);
  }
}
