import 'package:flutter/material.dart';

import '../../core/theme/app_espacios.dart';
import '../../core/theme/colores_app.dart';

/// Mensaje para cuando una lista no tiene nada que mostrar.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    required this.icono,
    required this.titulo,
    this.detalle,
  });

  final IconData icono;
  final String titulo;
  final String? detalle;

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquema;
    final detalle = this.detalle;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppEspacios.xl),
      child: Column(
        children: [
          Icon(icono, size: 40, color: esquema.onSurfaceVariant),
          const SizedBox(height: AppEspacios.s),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: context.textos.titleSmall,
          ),
          if (detalle != null) ...[
            const SizedBox(height: AppEspacios.xs),
            Text(
              detalle,
              textAlign: TextAlign.center,
              style: context.textos.bodyMedium?.copyWith(
                color: esquema.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
