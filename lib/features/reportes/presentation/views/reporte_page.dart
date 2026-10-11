import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/etiquetas_dominio.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_espacios.dart';
import '../../../../core/theme/colores_app.dart';
import '../../../../shared/widgets/acciones_barra.dart';
import '../../../../shared/widgets/dialogo_confirmar.dart';
import '../../../../shared/widgets/tarjeta_cifra.dart';
import '../../../sesion/presentation/views/boton_sesion.dart';
import '../../../visitas/domain/visita.dart';
import '../../domain/cierre_dia.dart';
import '../../domain/reporte_diario.dart';
import '../view_models/reporte_view_model.dart';

/// Reporte de cierre del día (base del PDF que pide AIDER).
class ReportePage extends ConsumerWidget {
  const ReportePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final reporte = ref.watch(reporteViewModelProvider);
    final cierre = ref.watch(cierreViewModelProvider);
    final generandoPdf =
        ref.watch(reportePdfViewModelProvider) == EstadoPdf.generando;

    // Crea el PDF y abre el menú para compartirlo (WhatsApp, guardar).
    Future<void> descargarPdf() async {
      final mensajero = ScaffoldMessenger.of(context);
      final listo = await ref
          .read(reportePdfViewModelProvider.notifier)
          .descargar(l10n);
      if (!listo) {
        mensajero.showSnackBar(SnackBar(content: Text(l10n.pdfError)));
      }
    }

    Future<void> cerrarDia() async {
      final detalle = [
        l10n.cierreConfirmarDetalle(
          reporte.totalGrupos,
          reporte.totalVisitantes,
        ),
        if (reporte.gruposSinSalida > 0)
          l10n.cierreSinSalida(reporte.gruposSinSalida),
      ].join('\n\n');
      final aceptado = await confirmar(
        context,
        titulo: l10n.cierreConfirmarTitulo,
        detalle: detalle,
        accion: l10n.cierreAccion,
      );
      if (!aceptado) return;
      ref.read(cierreViewModelProvider.notifier).cerrarDia();
    }

    return Scaffold(
      appBar: BarraAsociacion(
        titulo: l10n.reporteTitulo,
        acciones: const [BotonSesion()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppEspacios.l),
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: TarjetaCifra(
                    icono: Icons.groups_outlined,
                    etiqueta: l10n.reporteVisitantes,
                    valor: '${reporte.totalVisitantes}',
                    destacada: true,
                  ),
                ),
                const SizedBox(width: AppEspacios.s),
                Expanded(
                  child: TarjetaCifra(
                    icono: Icons.hiking,
                    etiqueta: l10n.reporteGrupos,
                    valor: '${reporte.totalGrupos}',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppEspacios.m),
          _Seccion(
            titulo: l10n.reporteProcedencia,
            filas: {
              for (final procedencia in Procedencia.values)
                procedencia.texto(l10n): ?reporte.porProcedencia[procedencia],
            },
          ),
          const SizedBox(height: AppEspacios.m),
          _Seccion(
            titulo: l10n.reporteEdades,
            filas: {
              for (final rango in RangoEdad.values)
                rango.texto(l10n): ?reporte.porRangoEdad[rango],
            },
          ),
          if (reporte.porGuia.isNotEmpty) ...[
            const SizedBox(height: AppEspacios.m),
            _PorGuia(porGuia: reporte.porGuia),
          ],
          const SizedBox(height: AppEspacios.l),
          if (cierre != null) ...[
            _CierreHecho(
              cierre: cierre,
              desactualizado: cierre.desactualizado(reporte),
            ),
            const SizedBox(height: AppEspacios.m),
          ],
          if (cierre == null || cierre.desactualizado(reporte)) ...[
            FilledButton.icon(
              onPressed: cerrarDia,
              icon: const Icon(Icons.task_alt),
              label: Text(
                cierre == null ? l10n.cierreBoton : l10n.cierreActualizar,
              ),
            ),
            const SizedBox(height: AppEspacios.s),
          ],
          OutlinedButton.icon(
            onPressed: generandoPdf ? null : descargarPdf,
            icon: generandoPdf
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf_outlined),
            label: Text(generandoPdf ? l10n.pdfGenerando : l10n.reportePdf),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta con barras horizontales: una fila por categoría.
class _Seccion extends StatelessWidget {
  const _Seccion({required this.titulo, required this.filas});

  final String titulo;
  final Map<String, int> filas;

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquema;
    final textos = context.textos;
    final maximo = filas.values.fold<int>(1, (m, v) => v > m ? v : m);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppEspacios.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(titulo, style: textos.titleSmall),
            ),
            const SizedBox(height: AppEspacios.s),
            if (filas.isEmpty)
              Text(
                context.l10n.reporteSinRegistros,
                style: textos.bodyMedium?.copyWith(
                  color: esquema.onSurfaceVariant,
                ),
              ),
            for (final fila in filas.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: MergeSemantics(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(fila.key, style: textos.bodyMedium),
                          ),
                          Text('${fila.value}', style: textos.titleSmall),
                        ],
                      ),
                      const SizedBox(height: AppEspacios.xs),
                      ExcludeSemantics(
                        child: LinearProgressIndicator(
                          value: fila.value / maximo,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Grupos y personas que registró cada guía en el día.
class _PorGuia extends StatelessWidget {
  const _PorGuia({required this.porGuia});

  final List<ResumenGuia> porGuia;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppEspacios.s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppEspacios.l),
              child: Text(
                l10n.reportePorGuia,
                style: context.textos.titleSmall,
              ),
            ),
            for (final guia in porGuia)
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: Text(guia.nombreGuia),
                subtitle: Text(
                  l10n.reporteGuiaDetalle(guia.grupos, guia.personas),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Constancia del cierre: quién cerró y a qué hora. Si hubo cambios
/// después, lo advierte.
class _CierreHecho extends StatelessWidget {
  const _CierreHecho({required this.cierre, required this.desactualizado});

  final CierreDia cierre;
  final bool desactualizado;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final esquema = context.esquema;
    final textos = context.textos;
    final hora = TimeOfDay.fromDateTime(cierre.cerradoEn).format(context);
    final (fondo, frente) = desactualizado
        ? (context.colores.aviso, context.colores.sobreAviso)
        : (esquema.primaryContainer, esquema.onPrimaryContainer);

    return Semantics(
      liveRegion: true,
      child: Container(
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(AppEspacios.radio),
        ),
        padding: const EdgeInsets.all(AppEspacios.l),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              desactualizado ? Icons.warning_amber : Icons.task_alt,
              color: frente,
            ),
            const SizedBox(width: AppEspacios.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.cierreHecho(hora, cierre.cerradoPor),
                    style: textos.titleSmall?.copyWith(color: frente),
                  ),
                  Text(
                    desactualizado
                        ? l10n.cierreDesactualizado
                        : l10n.cierreHechoDetalle,
                    style: textos.bodyMedium?.copyWith(color: frente),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
