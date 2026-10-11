import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/router/rutas.dart';
import '../../../../core/theme/app_espacios.dart';
import '../../../../core/theme/colores_app.dart';
import '../../../../shared/widgets/titulo_seccion.dart';
import '../../../conexion/domain/estado_conexion.dart';
import '../../../conexion/presentation/view_models/conexion_view_model.dart';
import '../../../mapa/presentation/view_models/mapa_view_model.dart';
import '../../domain/preferencias.dart';
import '../view_models/preferencias_view_model.dart';

/// Ajustes de la app: idioma (español o inglés) y apariencia (clara,
/// oscura o la del celular), que se guardan en el celular, y el estado de
/// la conexión con el servidor.
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

    // Arma la ruta de la sede alrededor de la posición GPS actual.
    Future<void> centrarRutaAqui() async {
      final mensajero = ScaffoldMessenger.of(context);
      final listo = await ref.read(centrarRutaAquiProvider)();
      mensajero.showSnackBar(
        SnackBar(
          content: Text(listo ? l10n.rutaCentrada : l10n.rutaCentrarError),
        ),
      );
    }

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
          TituloSeccion(l10n.ajustesRutaDemo),
          _GrupoOpciones(
            opciones: [
              _Opcion(
                icono: Icons.forest_outlined,
                titulo: l10n.rutaAngolo,
                detalle: l10n.rutaAngoloDetalle,
                seleccionada: preferencias.rutaDemo == RutaDemo.angolo,
                onTap: () => viewModel.cambiarRutaDemo(RutaDemo.angolo),
              ),
              _Opcion(
                icono: Icons.location_city_outlined,
                titulo: l10n.rutaSede,
                detalle: l10n.rutaSedeDetalle,
                seleccionada: preferencias.rutaDemo == RutaDemo.sede,
                // Al elegir la sede, la ruta se arma donde está el celular.
                onTap: () async {
                  await viewModel.cambiarRutaDemo(RutaDemo.sede);
                  await centrarRutaAqui();
                },
              ),
            ],
          ),
          const SizedBox(height: AppEspacios.s),
          Text(
            l10n.rutaCentrarAyuda,
            style: context.textos.bodySmall?.copyWith(
              color: context.esquema.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppEspacios.xs),
          OutlinedButton.icon(
            onPressed: centrarRutaAqui,
            icon: const Icon(Icons.my_location),
            label: Text(l10n.rutaCentrarAqui),
          ),
          const SizedBox(height: AppEspacios.s),
          OutlinedButton.icon(
            onPressed: () => context.push<void>(Rutas.qrPrueba),
            icon: const Icon(Icons.qr_code_2),
            label: Text(l10n.qrPruebaAbrir),
          ),
          TituloSeccion(l10n.ajustesServidor),
          const _TarjetaConexion(),
        ],
      ),
    );
  }
}

/// Intención visual del estado de la conexión. El color siempre va junto a
/// un icono y un texto que dicen lo mismo.
enum _Tono { neutro, exito, aviso, error }

/// Estado de la conexión con el servidor y botón para volver a probarla.
class _TarjetaConexion extends ConsumerWidget {
  const _TarjetaConexion();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final esquema = context.esquema;
    final colores = context.colores;
    final textos = context.textos;
    final conexion = ref.watch(conexionViewModelProvider);
    final probando = conexion is AsyncLoading;

    final (icono, titulo, detalle, tono) = switch (conexion) {
      AsyncData(value: SinConfigurar()) => (
        Icons.cloud_off_outlined,
        l10n.conexionSinConfigurar,
        l10n.conexionSinConfigurarDetalle,
        _Tono.neutro,
      ),
      AsyncData(value: Conectado(esquemaListo: true)) => (
        Icons.cloud_done_outlined,
        l10n.conexionConectado,
        l10n.conexionConectadoDetalle,
        _Tono.exito,
      ),
      AsyncData(value: Conectado()) => (
        Icons.cloud_done_outlined,
        l10n.conexionConectado,
        l10n.conexionSinEsquemaDetalle,
        _Tono.aviso,
      ),
      AsyncData(value: ClaveRechazada()) => (
        Icons.key_off_outlined,
        l10n.conexionClaveRechazada,
        l10n.conexionClaveRechazadaDetalle,
        _Tono.error,
      ),
      AsyncData(value: SinConexion()) => (
        Icons.wifi_off,
        l10n.conexionSinConexion,
        l10n.conexionSinConexionDetalle,
        _Tono.aviso,
      ),
      AsyncData(value: ErrorServidor(:final codigo)) => (
        Icons.error_outline,
        l10n.conexionError,
        l10n.conexionErrorDetalle(codigo),
        _Tono.error,
      ),
      AsyncError() => (
        Icons.error_outline,
        l10n.conexionError,
        null,
        _Tono.error,
      ),
      AsyncLoading() => (Icons.sync, l10n.conexionProbando, null, _Tono.neutro),
    };
    final (fondo, frente) = switch (tono) {
      _Tono.neutro => (
        esquema.surfaceContainerHighest,
        esquema.onSurfaceVariant,
      ),
      _Tono.exito => (esquema.primaryContainer, esquema.onPrimaryContainer),
      _Tono.aviso => (colores.aviso, colores.sobreAviso),
      _Tono.error => (esquema.errorContainer, esquema.onErrorContainer),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppEspacios.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              liveRegion: true,
              child: MergeSemantics(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: fondo,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icono, size: 22, color: frente),
                      ),
                    ),
                    const SizedBox(width: AppEspacios.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(titulo, style: textos.titleSmall),
                          if (detalle != null)
                            Text(
                              detalle,
                              style: textos.bodyMedium?.copyWith(
                                color: esquema.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppEspacios.m),
            OutlinedButton.icon(
              onPressed: probando
                  ? null
                  : ref.read(conexionViewModelProvider.notifier).probarDeNuevo,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.conexionProbar),
            ),
          ],
        ),
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
