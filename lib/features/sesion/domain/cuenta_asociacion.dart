/// Cuenta con la que una asociación entra al modo puesto de control. La crea
/// el portal web y la comparten todos los guías autorizados.
class CuentaAsociacion {
  const CuentaAsociacion({
    required this.asociacionId,
    required this.nombreAsociacion,
    required this.correo,
  });

  final String asociacionId;
  final String nombreAsociacion;
  final String correo;

  @override
  bool operator ==(Object other) =>
      other is CuentaAsociacion &&
      other.asociacionId == asociacionId &&
      other.nombreAsociacion == nombreAsociacion &&
      other.correo == correo;

  @override
  int get hashCode => Object.hash(asociacionId, nombreAsociacion, correo);
}
