import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_espacios.dart';
import '../../../../core/theme/colores_app.dart';
import '../../../../shared/widgets/titulo_seccion.dart';
import '../../domain/preferencias.dart';
import '../view_models/preferencias_view_model.dart';

/// Ajustes de la app: idioma (español o inglés) y apariencia (clara,
/// oscura o la del celular). Se guardan en el celular.
class AjustesPage extends ConsumerWidget {
  const AjustesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final preferencias = ref.watch(preferenciasViewModelProvider);
    final viewModel = ref.read(preferenciasViewModelProvider.notifier);
    // Idioma que se está mostrando: el elegido o el del celular.
    final idiomaActual = Idioma.deCodigo(
      Localizations.localeOf(context).languageCode,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ajustes)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppEspacios.l,
          0,
          AppEspacios.l,
          AppEspacios.xl,
        ),
        children: [
          TituloSeccion(l10n.ajustesIdioma),
          _GrupoOpciones(
            opciones: [
              _Opcion(
                icono: Icons.language,
                titulo: l10n.idiomaEspanol,
                seleccionada: idiomaActual == Idioma.es,
                onTap: () => viewModel.cambiarIdioma(Idioma.es),
              ),
              _Opcion(
                icono: Icons.language,
                titulo: l10n.idiomaIngles,
                seleccionada: idiomaActual == Idioma.en,
                onTap: () => viewModel.cambiarIdioma(Idioma.en),
              ),
            ],
          ),
          TituloSeccion(l10n.ajustesApariencia),
          _GrupoOpciones(
            opciones: [
              _Opcion(
                icono: Icons.brightness_auto_outlined,
                titulo: l10n.temaSistema,
                detalle: l10n.temaSistemaDetalle,
                seleccionada: preferencias.modoTema == ModoTema.sistema,
                onTap: () => viewModel.cambiarModoTema(ModoTema.sistema),
              ),
              _Opcion(
                icono: Icons.light_mode_outlined,
                titulo: l10n.temaClaro,
                detalle: l10n.temaClaroDetalle,
                seleccionada: preferencias.modoTema == ModoTema.claro,
                onTap: () => viewModel.cambiarModoTema(ModoTema.claro),
              ),
              _Opcion(
                icono: Icons.dark_mode_outlined,
                titulo: l10n.temaOscuro,
                detalle: l10n.temaOscuroDetalle,
                seleccionada: preferencias.modoTema == ModoTema.oscuro,
                onTap: () => viewModel.cambiarModoTema(ModoTema.oscuro),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tarjeta con opciones de las que solo se elige una.
class _GrupoOpciones extends StatelessWidget {
  const _GrupoOpciones({required this.opciones});

  final List<_Opcion> opciones;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (indice, opcion) in opciones.indexed) ...[
            if (indice > 0) const Divider(),
            opcion,
          ],
        ],
      ),
    );
  }
}

class _Opcion extends StatelessWidget {
  const _Opcion({
    required this.icono,
    required this.titulo,
    required this.seleccionada,
    required this.onTap,
    this.detalle,
  });

  final IconData icono;
  final String titulo;
  final String? detalle;
  final bool seleccionada;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquema;
    final detalle = this.detalle;

    return ListTile(
      minTileHeight: 60,
      selected: seleccionada,
      leading: Icon(icono),
      title: Text(
        titulo,
        style: context.textos.titleSmall?.copyWith(
          color: seleccionada ? esquema.primary : esquema.onSurface,
        ),
      ),
      subtitle: detalle == null ? null : Text(detalle),
      trailing: Icon(
        seleccionada ? Icons.radio_button_checked : Icons.radio_button_off,
        color: seleccionada ? esquema.primary : esquema.outline,
      ),
      onTap: onTap,
    );
  }
}
