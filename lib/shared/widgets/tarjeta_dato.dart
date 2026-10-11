import 'package:flutter/material.dart';

import '../../core/theme/app_espacios.dart';
import '../../core/theme/colores_app.dart';

/// Tarjeta pequeña con una etiqueta y un valor (por ejemplo, "Pago:
/// Efectivo · Yape"). Crece con el texto: no tiene alto fijo.
class TarjetaDato extends StatelessWidget {
  const TarjetaDato({
    super.key,
    required this.etiqueta,
    required this.valor,
    this.icono,
  });

  final String etiqueta;
  final String valor;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquema;
    final icono = this.icono;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppEspacios.m),
        child: MergeSemantics(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icono != null) ...[
                Icon(icono, size: 22, color: esquema.primary),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      etiqueta.toUpperCase(),
                      semanticsLabel: etiqueta,
                      style: context.textos.labelSmall?.copyWith(
                        color: esquema.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(valor, style: context.textos.titleSmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
