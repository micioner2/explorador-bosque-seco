import 'package:flutter/material.dart';

import '../../core/theme/colores_app.dart';

/// Icono decorativo dentro de un círculo suave, para encabezar tarjetas.
/// No se anuncia en los lectores de pantalla: el texto de al lado ya lo dice.
class IconoCircular extends StatelessWidget {
  const IconoCircular(this.icono, {super.key, this.lado = 44});

  final IconData icono;
  final double lado;

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquema;

    return ExcludeSemantics(
      child: Container(
        width: lado,
        height: lado,
        decoration: BoxDecoration(
          color: esquema.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(icono, size: lado * 0.5, color: esquema.onPrimaryContainer),
      ),
    );
  }
}
