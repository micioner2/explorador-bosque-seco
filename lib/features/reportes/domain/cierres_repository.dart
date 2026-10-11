import 'cierre_dia.dart';

/// Cierres del día guardados en el celular.
abstract interface class CierresRepository {
  /// Cierre de [dia] de la asociación, o `null` si aún no se cerró.
  CierreDia? cierreDe(DateTime dia, String asociacionId);

  /// Guarda el cierre; si ya había uno de ese día, lo reemplaza.
  Future<void> guardar(CierreDia cierre);
}
