import 'package:flutter/material.dart';

import '../../core/theme/app_espacios.dart';
import '../../core/theme/colores_app.dart';

/// Cabecera que continúa el color de la barra superior, para lo primero
/// que debe verse en una pantalla del modo turista.
class Encabezado extends StatelessWidget {
  const Encabezado({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colores.encabezado,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppEspacios.xl),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppEspacios.l,
        AppEspacios.xs,
        AppEspacios.l,
        AppEspacios.xl,
      ),
      child: IconTheme.merge(
        data: IconThemeData(color: colores.sobreEncabezado),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: colores.sobreEncabezado),
          child: child,
        ),
      ),
    );
  }
}
