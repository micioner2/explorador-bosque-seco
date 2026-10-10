import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Lector de QR de los puntos turísticos.
///
/// Siguiente paso: integrar `mobile_scanner` y registrar el escaneo en el
/// pasaporte con `Pasaporte.registrar`.
class EscanearPage extends StatelessWidget {
  const EscanearPage({super.key});

  @override
  Widget build(BuildContext context) {
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
          ],
        ),
      ),
    );
  }
}
