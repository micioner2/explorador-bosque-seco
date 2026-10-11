import 'package:flutter/material.dart';

import '../../core/theme/app_espacios.dart';
import '../../core/theme/colores_app.dart';

/// Título de una sección dentro de una pantalla. Los lectores de pantalla
/// lo anuncian como encabezado.
class TituloSeccion extends StatelessWidget {
  const TituloSeccion(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppEspacios.xl,
        bottom: AppEspacios.m,
      ),
      child: Semantics(
        header: true,
        child: Text(
          texto,
          style: context.textos.titleMedium?.copyWith(
            color: context.esquema.primary,
          ),
        ),
      ),
    );
  }
}
