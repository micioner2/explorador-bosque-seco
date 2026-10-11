import 'reporte_diario.dart';

/// Cierre del día del puesto de control: reemplaza la firma al pie de la
/// hoja del cuaderno. Guarda las cifras tal como estaban al cerrar, quién
/// cerró y a qué hora (regla R17).
class CierreDia {
  CierreDia({
    required this.dia,
    required this.asociacionId,
    required this.cerradoEn,
    required String cerradoPor,
    required this.totalGrupos,
    required this.totalVisitantes,
    required this.gruposSinSalida,
    required Iterable<ResumenGuia> porGuia,
  }) : cerradoPor = cerradoPor.trim(),
       porGuia = List.unmodifiable(porGuia) {
    if (this.cerradoPor.isEmpty) {
      throw ArgumentError.value(cerradoPor, 'cerradoPor', 'Falta el guía');
    }
    if (cerradoEn.isBefore(dia)) {
      throw ArgumentError.value(cerradoEn, 'cerradoEn', 'Antes del día');
    }
  }

  /// Cierra el día de [reporte] con sus cifras actuales.
  factory CierreDia.desde(
    ReporteDiario reporte, {
    required String asociacionId,
    required String cerradoPor,
    required DateTime ahora,
  }) => CierreDia(
    dia: reporte.dia,
    asociacionId: asociacionId,
    cerradoEn: ahora,
    cerradoPor: cerradoPor,
    totalGrupos: reporte.totalGrupos,
    totalVisitantes: reporte.totalVisitantes,
    gruposSinSalida: reporte.gruposSinSalida,
    porGuia: reporte.porGuia,
  );

  /// Día cerrado (a medianoche).
  final DateTime dia;
  final String asociacionId;
  final DateTime cerradoEn;

  /// Guía que cerró el día desde el celular.
  final String cerradoPor;
  final int totalGrupos;
  final int totalVisitantes;
  final int gruposSinSalida;
  final List<ResumenGuia> porGuia;

  /// Después de cerrar se registró o cambió algo: conviene volver a cerrar.
  bool desactualizado(ReporteDiario reporte) =>
      reporte.totalGrupos != totalGrupos ||
      reporte.totalVisitantes != totalVisitantes ||
      reporte.gruposSinSalida != gruposSinSalida;
}
