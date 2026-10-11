/// Rutas de la app, en un solo lugar para no repetir textos.
abstract final class Rutas {
  static const explorar = '/explorar';
  static const mapa = '/mapa';
  static const pasaporte = '/pasaporte';
  static const escanear = '/escanear';
  static const ajustes = '/ajustes';

  /// QR de prueba de los puntos (para probar el escaneo y la demo).
  static const qrPrueba = '/qr-prueba';

  /// Entrada al puesto de control: cuenta de la asociación y luego el guía.
  static const acceso = '/acceso';
  static const accesoGuia = '/acceso/guia';

  static const asociacionHoy = '/asociacion';
  static const asociacionReservas = '/asociacion/reservas';
  static const asociacionRegistrar = '/asociacion/registrar';
  static const asociacionReporte = '/asociacion/reporte';

  static const reservaNueva = '/asociacion/reservas/nueva';
  static const reservaReprogramar = '/asociacion/reservas/:id/reprogramar';

  static String reprogramarReserva(String id) =>
      '/asociacion/reservas/$id/reprogramar';
}
