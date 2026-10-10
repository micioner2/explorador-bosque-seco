import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/tarjeta_dato.dart';
import '../../domain/visita.dart';
import '../view_models/visitas_view_model.dart';

/// Panel del puesto de control: quién está dentro del bosque y alertas.
class HoyPage extends ConsumerWidget {
  const HoyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumen = ref.watch(resumenDelDiaProvider);
    final viewModel = ref.read(visitasViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Hoy en el puesto de control')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: TarjetaDato(
                  etiqueta: 'Dentro',
                  valor: '${resumen.personasDentro}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TarjetaDato(
                  etiqueta: 'Salieron',
                  valor: '${resumen.personasQueSalieron}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TarjetaDato(
                  etiqueta: 'Total',
                  valor: '${resumen.personasTotal}',
                ),
              ),
            ],
          ),
          for (final visita in resumen.atrasadas)
            _AlertaSigueDentro(visita: visita),
          const SizedBox(height: 16),
          const Text(
            'Dentro del bosque',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.verdeOscuro,
            ),
          ),
          const SizedBox(height: 8),
          if (resumen.dentro.isEmpty) const Text('No hay grupos dentro.'),
          for (final visita in resumen.dentro)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(
                  '${visita.nombreResponsable} · '
                  '${visita.tamanoGrupo} personas',
                ),
                subtitle: Text(visita.actividad.etiqueta),
                trailing: OutlinedButton(
                  onPressed: () => viewModel.marcarSalida(visita.id),
                  child: const Text('Marcar salida'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AlertaSigueDentro extends StatelessWidget {
  const _AlertaSigueDentro({required this.visita});

  final Visita visita;

  @override
  Widget build(BuildContext context) {
    final hora = TimeOfDay.fromDateTime(visita.salidaPrevista).format(context);
    return Card(
      margin: const EdgeInsets.only(top: 12),
      color: const Color(0xFFFDEBDD),
      child: ListTile(
        leading: const Icon(
          Icons.warning_amber_rounded,
          color: AppColors.alerta,
        ),
        title: Text(
          'Sigue dentro: ${visita.nombreResponsable}',
          style: const TextStyle(
            color: AppColors.alerta,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text('Debía salir a las $hora'),
      ),
    );
  }
}
