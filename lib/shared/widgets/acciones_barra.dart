import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n.dart';
import '../../core/router/rutas.dart';
import '../../core/theme/colores_app.dart';

/// Botón de la barra superior que abre Ajustes (idioma y apariencia).
class BotonAjustes extends StatelessWidget {
  const BotonAjustes({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: context.l10n.ajustes,
      icon: const Icon(Icons.settings_outlined),
      onPressed: () => context.push<void>(Rutas.ajustes),
    );
  }
}

/// Barra superior del modo asociación. Tiene otro color que la del modo
/// turista para que se note en qué modo está la app, y siempre ofrece
/// volver al modo turista.
class BarraAsociacion extends StatelessWidget implements PreferredSizeWidget {
  const BarraAsociacion({
    super.key,
    required this.titulo,
    this.acciones = const [],
  });

  final String titulo;

  /// Botones propios de la pantalla, antes de "modo turista" y Ajustes.
  final List<Widget> acciones;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;

    return AppBar(
      backgroundColor: colores.barraAsociacion,
      foregroundColor: colores.sobreBarraAsociacion,
      title: Text(titulo),
      actions: [
        ...acciones,
        IconButton(
          tooltip: context.l10n.modoTurista,
          icon: const Icon(Icons.hiking),
          onPressed: () => context.go(Rutas.explorar),
        ),
        const BotonAjustes(),
      ],
    );
  }
}
