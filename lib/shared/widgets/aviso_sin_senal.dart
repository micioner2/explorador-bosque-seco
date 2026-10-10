import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Aviso que recuerda al turista que su información está guardada en el
/// celular y que funciona sin señal.
class AvisoSinSenal extends StatelessWidget {
  const AvisoSinSenal({
    super.key,
    this.mensaje = 'Sin señal · tu ruta está guardada en el celular',
  });

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.amarilloCrema,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: AppColors.marronTierra, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(
                color: AppColors.marronTierra,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
