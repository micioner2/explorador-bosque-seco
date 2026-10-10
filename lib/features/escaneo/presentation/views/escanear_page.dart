import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../puntos/domain/pasaporte.dart';
import '../../../puntos/presentation/view_models/pasaporte_view_model.dart';

/// Lector de QR de los puntos turísticos.
///
/// Siguiente paso: integrar `mobile_scanner`. Mientras tanto, el botón de
/// demostración registra el punto "mirador" con la misma lógica real.
class EscanearPage extends ConsumerWidget {
  const EscanearPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void registrarDemo() {
      final resultado = ref
          .read(pasaporteViewModelProvider.notifier)
          .registrarEscaneo(visitaId: 'v-demo', puntoId: 'mirador');
      final mensaje = switch (resultado) {
        PuntoGanado() => '¡Sello obtenido! +1 punto',
        PuntoYaRegistrado() => 'Este punto ya está en tu pasaporte',
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensaje)));
    }

    return Scaffold(
      backgroundColor: AppColors.negroGrisaceo,
      appBar: AppBar(
        title: const Text('Escanear punto'),
        backgroundColor: AppColors.negroGrisaceo,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.amarilloCrema, width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                size: 96,
                color: AppColors.amarilloCrema,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Apunta al QR del punto turístico',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.amarilloCrema,
                side: const BorderSide(color: AppColors.amarilloCrema),
              ),
              onPressed: registrarDemo,
              child: const Text('Simular escaneo (demo)'),
            ),
          ],
        ),
      ),
    );
  }
}
