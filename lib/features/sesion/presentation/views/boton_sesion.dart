import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/router/rutas.dart';
import '../../../../core/theme/app_espacios.dart';
import '../../../../shared/widgets/dialogo_confirmar.dart';
import '../../../../shared/widgets/tarjeta_dato.dart';
import '../view_models/sesion_view_model.dart';

/// Botón de la barra del puesto de control que muestra quién está
/// registrando y permite cambiar de guía o salir de la cuenta.
class BotonSesion extends StatelessWidget {
  const BotonSesion({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: context.l10n.sesionTooltip,
      icon: const Icon(Icons.account_circle_outlined),
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => const _HojaSesion(),
      ),
    );
  }
}

class _HojaSesion extends ConsumerWidget {
  const _HojaSesion();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final sesion = ref.watch(sesionViewModelProvider);
    final viewModel = ref.read(sesionViewModelProvider.notifier);
    final cuenta = sesion.cuenta;
    final guia = sesion.guia;

    void cambiarGuia() {
      Navigator.of(context).pop();
      // El router lleva solo a "¿Quién eres?".
      viewModel.cambiarGuia();
    }

    Future<void> salir() async {
      final aceptado = await confirmar(
        context,
        titulo: l10n.sesionSalirTitulo,
        detalle: l10n.sesionSalirDetalle,
        accion: l10n.sesionSalirAccion,
      );
      if (!aceptado || !context.mounted) return;
      final router = GoRouter.of(context);
      Navigator.of(context).pop();
      router.go(Rutas.explorar);
      await viewModel.cerrarSesion();
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppEspacios.l,
          0,
          AppEspacios.l,
          AppEspacios.l,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (cuenta != null) ...[
              TarjetaDato(
                icono: Icons.storefront_outlined,
                etiqueta: l10n.sesionAsociacion,
                valor: cuenta.nombreAsociacion,
              ),
              const SizedBox(height: AppEspacios.s),
            ],
            if (guia != null)
              TarjetaDato(
                icono: Icons.badge_outlined,
                etiqueta: l10n.sesionGuia,
                valor: guia.nombre,
              ),
            const SizedBox(height: AppEspacios.xl),
            FilledButton.icon(
              onPressed: cambiarGuia,
              icon: const Icon(Icons.swap_horiz),
              label: Text(l10n.sesionCambiarGuia),
            ),
            const SizedBox(height: AppEspacios.s),
            OutlinedButton.icon(
              onPressed: salir,
              icon: const Icon(Icons.logout),
              label: Text(l10n.sesionSalir),
            ),
          ],
        ),
      ),
    );
  }
}
