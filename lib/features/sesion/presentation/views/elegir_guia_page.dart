import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/router/rutas.dart';
import '../../../../core/theme/app_espacios.dart';
import '../../../../core/theme/colores_app.dart';
import '../../../../shared/widgets/acciones_barra.dart';
import '../../../../shared/widgets/dialogo_confirmar.dart';
import '../../../../shared/widgets/estado_vacio.dart';
import '../../domain/guia.dart';
import '../view_models/sesion_view_model.dart';
import 'cabecera_acceso.dart';

/// Paso 2 para entrar al puesto de control: el guía toca su nombre. Las
/// visitas que registre quedarán a su nombre. Funciona sin señal: la lista
/// de guías está guardada en el celular.
class ElegirGuiaPage extends ConsumerWidget {
  const ElegirGuiaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final cuenta = ref.watch(sesionViewModelProvider).cuenta;
    final ultimo = ref.watch(ultimoGuiaViewModelProvider);
    // El último guía se ofrece arriba con un botón grande; el resto, abajo.
    final guias = [
      for (final guia in ref.watch(guiasDeLaCuentaProvider))
        if (guia != ultimo) guia,
    ];
    final viewModel = ref.read(sesionViewModelProvider.notifier);

    void elegir(Guia guia) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.guiaBienvenida(guia.nombre))));
      // El router lleva solo al puesto de control.
      viewModel.elegirGuia(guia);
    }

    Future<void> salir() async {
      final aceptado = await confirmar(
        context,
        titulo: l10n.sesionSalirTitulo,
        detalle: l10n.sesionSalirDetalle,
        accion: l10n.sesionSalirAccion,
      );
      if (!aceptado || !context.mounted) return;
      context.go(Rutas.explorar);
      await viewModel.cerrarSesion();
    }

    return Scaffold(
      appBar: BarraAsociacion(titulo: l10n.modoAsociacion),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppEspacios.xl),
        children: [
          CabeceraAcceso(
            paso: 2,
            icono: Icons.badge_outlined,
            titulo: l10n.guiaTitulo,
            detalle: l10n.guiaAyuda,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppEspacios.l,
              AppEspacios.l,
              AppEspacios.l,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (cuenta != null)
                  _NombreAsociacion(nombre: cuenta.nombreAsociacion),
                const SizedBox(height: AppEspacios.m),
                if (ultimo != null) ...[
                  _ContinuarComo(guia: ultimo, onTap: () => elegir(ultimo)),
                  if (guias.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppEspacios.xl,
                        bottom: AppEspacios.s,
                      ),
                      child: Text(
                        l10n.guiaOtro,
                        style: context.textos.titleSmall,
                      ),
                    ),
                ] else if (guias.isEmpty)
                  EstadoVacio(
                    icono: Icons.group_off_outlined,
                    titulo: l10n.guiaSinGuias,
                    detalle: l10n.guiaSinGuiasDetalle,
                  ),
                for (final guia in guias)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppEspacios.s),
                    child: _TarjetaGuia(guia: guia, onTap: () => elegir(guia)),
                  ),
                const SizedBox(height: AppEspacios.l),
                OutlinedButton.icon(
                  onPressed: salir,
                  icon: const Icon(Icons.logout),
                  label: Text(l10n.sesionSalir),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Asociación de la cuenta abierta, para confirmar que es la correcta.
class _NombreAsociacion extends StatelessWidget {
  const _NombreAsociacion({required this.nombre});

  final String nombre;

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquema;

    return MergeSemantics(
      child: Row(
        children: [
          Icon(Icons.storefront_outlined, color: esquema.primary),
          const SizedBox(width: AppEspacios.s),
          Expanded(
            child: Text(
              nombre,
              style: context.textos.titleSmall?.copyWith(
                color: esquema.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón grande para el guía que usó el celular la última vez: entrar es
/// un solo toque.
class _ContinuarComo extends StatelessWidget {
  const _ContinuarComo({required this.guia, required this.onTap});

  final Guia guia;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(64)),
          onPressed: onTap,
          icon: const Icon(Icons.login),
          label: Text(l10n.guiaContinuarComo(guia.nombre)),
        ),
        const SizedBox(height: AppEspacios.xs),
        Text(
          l10n.guiaUltimaVez,
          textAlign: TextAlign.center,
          style: context.textos.bodySmall?.copyWith(
            color: context.esquema.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Un guía de la lista: grande y fácil de tocar, con sus iniciales.
class _TarjetaGuia extends StatelessWidget {
  const _TarjetaGuia({required this.guia, required this.onTap});

  final Guia guia;
  final VoidCallback onTap;

  /// "María Quispe" → "MQ".
  String get _iniciales => guia.nombre
      .split(RegExp(r'\s+'))
      .take(2)
      .map((parte) => parte.characters.first.toUpperCase())
      .join();

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquema;
    final textos = context.textos;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        minTileHeight: 72,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppEspacios.l),
        leading: ExcludeSemantics(
          child: CircleAvatar(
            radius: 24,
            backgroundColor: esquema.primaryContainer,
            child: Text(
              _iniciales,
              style: textos.titleSmall?.copyWith(
                color: esquema.onPrimaryContainer,
              ),
              textScaler: TextScaler.noScaling,
            ),
          ),
        ),
        title: Text(guia.nombre, style: textos.titleMedium),
        trailing: Icon(Icons.chevron_right, color: esquema.primary),
        onTap: onTap,
      ),
    );
  }
}
