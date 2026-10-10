import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Tarjeta pequeña con una etiqueta y un valor (por ejemplo, "Pago:
/// Efectivo · Yape" o "Dentro: 8").
class TarjetaDato extends StatelessWidget {
  const TarjetaDato({super.key, required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              etiqueta.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 0.4,
                color: AppColors.textoSecundario,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              valor,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.negroGrisaceo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
