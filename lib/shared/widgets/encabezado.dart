import 'package:flutter/material.dart';

import '../../core/theme/app_espacios.dart';
import '../../core/theme/colores_app.dart';

/// Cabecera que continúa el color de la barra superior, para lo primero
/// que debe verse en una pantalla: verde en el modo turista y marrón en el
/// modo asociación ([deAsociacion]).
class Encabezado extends StatelessWidget {
  const Encabezado({super.key, required this.child, this.deAsociacion = false});

  final Widget child;
  final bool deAsociacion;

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final fondo = deAsociacion ? colores.barraAsociacion : colores.encabezado;
    final frente = deAsociacion
        ? colores.sobreBarraAsociacion
        : colores.sobreEncabezado;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: fondo,
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
        data: IconThemeData(color: frente),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: frente),
          child: child,
        ),
      ),
    );
  }
}
