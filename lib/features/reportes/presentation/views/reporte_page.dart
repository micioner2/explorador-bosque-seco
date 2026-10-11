import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/etiquetas_dominio.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_espacios.dart';
import '../../../../core/theme/colores_app.dart';
import '../../../../shared/widgets/acciones_barra.dart';
import '../../../../shared/widgets/tarjeta_cifra.dart';
import '../../../visitas/domain/visita.dart';
import '../../domain/reporte_diario.dart';
import '../view_models/reporte_view_model.dart';

/// Reporte de cierre del día (base del PDF que pide AIDER).
class ReportePage extends ConsumerWidget {
  const ReportePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final reporte = ref.watch(reporteViewModelProvider);

    return Scaffold(
      appBar: BarraAsociacion(titulo: l10n.reporteTitulo),
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
          const SizedBox(height: AppEspacios.l),
          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.reportePdfAviso))),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: Text(l10n.reportePdf),
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
