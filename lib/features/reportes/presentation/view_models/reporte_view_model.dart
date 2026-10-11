import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/etiquetas_dominio.dart';
import '../../../../core/l10n/formato.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/reloj.dart';
import '../../../mapa/presentation/view_models/mapa_view_model.dart';
import '../../../puntos/presentation/view_models/pasaporte_view_model.dart';
import '../../../sesion/presentation/view_models/sesion_view_model.dart';
import '../../../visitas/domain/visita.dart';
import '../../../visitas/presentation/view_models/visitas_view_model.dart';
import '../../data/cierres_repository_local.dart';
import '../../data/generador_pdf_reporte.dart';
import '../../domain/cierre_dia.dart';
import '../../domain/documento_reporte.dart';
import '../../domain/reporte_diario.dart';

/// Reporte del día calculado a partir de las visitas y escaneos actuales.
final reporteViewModelProvider = Provider<ReporteDiario>(
  (ref) => ReporteDiario.calcular(
    dia: ref.watch(relojProvider)(),
    visitas: ref.watch(visitasViewModelProvider),
    escaneos: ref.watch(pasaporteViewModelProvider).escaneos,
  ),
);

/// Cierre del día de hoy de la asociación, o `null` si aún no se cerró.
class CierreViewModel extends Notifier<CierreDia?> {
  @override
  CierreDia? build() {
    final cuenta = ref.watch(sesionViewModelProvider.select((s) => s.cuenta));
    if (cuenta == null) return null;
    return ref
        .watch(cierresRepositoryProvider)
        .cierreDe(ref.watch(relojProvider)(), cuenta.asociacionId);
  }

  /// Cierra el día (o actualiza el cierre) a nombre del guía de la sesión.
  /// Lanza [StateError] si no hay guía elegido.
  CierreDia cerrarDia() {
    final (:cuenta, :guia) = ref.read(sesionViewModelProvider).quienRegistra();
    final cierre = CierreDia.desde(
      ref.read(reporteViewModelProvider),
      asociacionId: cuenta.asociacionId,
      cerradoPor: guia.nombre,
      ahora: ref.read(relojProvider)(),
    );
    state = cierre;
    ref.read(cierresRepositoryProvider).guardar(cierre);
    return cierre;
  }
}

final cierreViewModelProvider = NotifierProvider<CierreViewModel, CierreDia?>(
  CierreViewModel.new,
);

/// Qué está pasando con el PDF del día.
enum EstadoPdf { listo, generando, error }

/// Arma el PDF del reporte del día y abre el menú para compartirlo
/// (WhatsApp, guardar). Todo ocurre en el celular: funciona en modo avión.
class ReportePdfViewModel extends Notifier<EstadoPdf> {
  @override
  EstadoPdf build() => EstadoPdf.listo;

  /// Devuelve `true` si el PDF se creó y se abrió el menú de compartir. Si
  /// algo falla, el estado queda en [EstadoPdf.error] y devuelve `false`.
  Future<bool> descargar(AppLocalizations l10n) async {
    if (state == EstadoPdf.generando) return false;
    state = EstadoPdf.generando;
    try {
      final documento = _documento(l10n);
      final bytes = await ref.read(generadorReporteProvider).generar(documento);
      await ref
          .read(compartirArchivoProvider)
          .compartir(bytes, nombreArchivo: documento.nombreArchivo);
      if (!ref.mounted) return true;
      state = EstadoPdf.listo;
      return true;
    } on Object catch (error) {
      debugPrint('No se pudo crear el PDF del reporte: $error');
      if (ref.mounted) state = EstadoPdf.error;
      return false;
    }
  }

  DocumentoReporte _documento(AppLocalizations l10n) {
    final idioma = l10n.localeName;
    final ahora = ref.read(relojProvider)();
    final reporte = ref.read(reporteViewModelProvider);
    final cierre = ref.read(cierreViewModelProvider);
    final asociacion = ref.read(sesionViewModelProvider).cuenta;
    final puntos = {
      for (final punto in ref.read(rutaActualProvider).puntos)
        punto.id: punto.nombre,
    };
    final dia = reporte.dia;
    String dosCifras(int n) => n.toString().padLeft(2, '0');

    return DocumentoReporte(
      marca: l10n.pdfMarca,
      titulo: l10n.reporteTitulo,
      encabezado: [
        ?asociacion?.nombreAsociacion,
        formatearFecha(dia, idioma),
        if (cierre == null)
          l10n.pdfSinCierre
        else
          l10n.cierreHecho(
            formatearHora(cierre.cerradoEn, idioma),
            cierre.cerradoPor,
          ),
      ],
      cifras: [
        CifraReporte(l10n.reporteVisitantes, reporte.totalVisitantes),
        CifraReporte(l10n.reporteGrupos, reporte.totalGrupos),
        CifraReporte(l10n.pdfSinSalida, reporte.gruposSinSalida),
      ],
      alerta: reporte.gruposSinSalida > 0
          ? l10n.cierreSinSalida(reporte.gruposSinSalida)
          : null,
      secciones: [
        SeccionReporte(
          titulo: l10n.reporteProcedencia,
          filas: [
            for (final procedencia in Procedencia.values)
              if (reporte.porProcedencia[procedencia] case final n?)
                FilaReporte(procedencia.texto(l10n), n),
          ],
        ),
        SeccionReporte(
          titulo: l10n.reporteEdades,
          filas: [
            for (final rango in RangoEdad.values)
              if (reporte.porRangoEdad[rango] case final n?)
                FilaReporte(rango.texto(l10n), n),
          ],
        ),
        SeccionReporte(
          titulo: l10n.reportePorGuia,
          filas: [
            for (final guia in reporte.porGuia)
              FilaReporte(
                guia.nombreGuia,
                guia.personas,
                detalle: l10n.reporteGuiaDetalle(guia.grupos, guia.personas),
              ),
          ],
        ),
        SeccionReporte(
          titulo: l10n.pdfPuntos,
          filas: [
            for (final MapEntry(key: id, value: n)
                in reporte.puntosMasVisitados)
              FilaReporte(puntos[id] ?? id, n),
          ],
        ),
      ],
      textoSinDatos: l10n.pdfSinDatos,
      nota: l10n.pdfNota(
        '${formatearFechaCorta(ahora, idioma)} ${formatearHora(ahora, idioma)}',
      ),
      nombreArchivo:
          'reporte-${dia.year}-${dosCifras(dia.month)}-${dosCifras(dia.day)}.pdf',
    );
  }
}

final reportePdfViewModelProvider =
    NotifierProvider<ReportePdfViewModel, EstadoPdf>(ReportePdfViewModel.new);
