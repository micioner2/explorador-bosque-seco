import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/tarjeta_dato.dart';
import '../view_models/reporte_view_model.dart';

/// Reporte de cierre del día (base del PDF que pide AIDER).
class ReportePage extends ConsumerWidget {
  const ReportePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reporte = ref.watch(reporteViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reporte del día')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: TarjetaDato(
                  etiqueta: 'Visitantes',
                  valor: '${reporte.totalVisitantes}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TarjetaDato(
                  etiqueta: 'Grupos',
                  valor: '${reporte.totalGrupos}',
                ),
              ),
            ],
          ),
          _Seccion(
            titulo: 'Procedencia',
            filas: {
              for (final e in reporte.porProcedencia.entries)
                e.key.etiqueta: e.value,
            },
          ),
          _Seccion(
            titulo: 'Edades (responsable del grupo)',
            filas: {
              for (final e in reporte.porRangoEdad.entries)
                e.key.etiqueta: e.value,
            },
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Descargar PDF'),
          ),
        ],
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({required this.titulo, required this.filas});

  final String titulo;
  final Map<String, int> filas;

  @override
  Widget build(BuildContext context) {
    final maximo = filas.values.fold<int>(1, (m, v) => v > m ? v : m);
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (filas.isEmpty) const Text('Sin registros hoy'),
            for (final fila in filas.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(width: 110, child: Text(fila.key)),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: fila.value / maximo,
                        minHeight: 10,
                        color: AppColors.verdeInstitucional,
                        backgroundColor: AppColors.verdeSuave,
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      child: Text('${fila.value}', textAlign: TextAlign.end),
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
