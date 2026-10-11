import 'package:flutter/material.dart';

import '../../core/theme/app_espacios.dart';
import '../../core/theme/colores_app.dart';

/// Tarjeta con una cifra grande y su etiqueta (por ejemplo, "8 Dentro").
/// La cifra [destacada] es la que más importa en la pantalla.
class TarjetaCifra extends StatelessWidget {
  const TarjetaCifra({
    super.key,
    required this.etiqueta,
    required this.valor,
    required this.icono,
    this.destacada = false,
  });

  final String etiqueta;
  final String valor;
  final IconData icono;
  final bool destacada;

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquema;
    final frente = destacada ? esquema.onPrimaryContainer : esquema.onSurface;

    return Card(
      color: destacada ? esquema.primaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(AppEspacios.m),
        child: MergeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icono,
                size: 22,
                color: destacada ? frente : esquema.primary,
              ),
              const SizedBox(height: AppEspacios.s),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  valor,
                  style: context.textos.headlineMedium?.copyWith(
                    color: frente,
                    height: 1.1,
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  etiqueta,
                  style: context.textos.labelMedium?.copyWith(
                    color: destacada ? frente : esquema.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
