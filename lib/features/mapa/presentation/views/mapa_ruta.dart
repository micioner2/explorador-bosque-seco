import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/l10n/formato.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_espacios.dart';
import '../../../../core/theme/colores_app.dart';
import '../../domain/coordenada.dart';
import '../../domain/progreso_ruta.dart';
import '../../domain/ubicacion_repository.dart';
import '../view_models/mapa_view_model.dart';

LatLng _aLatLng(Coordenada c) => LatLng(c.latitud, c.longitud);

/// Ajuste de cámara que muestra toda la ruta.
CameraFit _ajusteRuta(ProgresoRuta progreso) => CameraFit.coordinates(
  coordinates: [for (final c in progreso.ruta.camino) _aLatLng(c)],
  padding: const EdgeInsets.all(40),
  maxZoom: 16,
);

/// Capas del mapa que comparten la vista incrustada y la de pantalla
/// completa: el camino, los puntos con su estado y la posición GPS. Si la
/// app trae las teselas del mapa base, se dibujan debajo; si no, el fondo es
/// liso.
List<Widget> _capasRuta(
  BuildContext context, {
  required ProgresoRuta progreso,
  required bool hayTeselas,
  required Coordenada? posicion,
}) {
  final l10n = context.l10n;
  final esquema = context.esquema;
  final siguiente = progreso.siguiente;

  return [
    if (hayTeselas)
      TileLayer(
        urlTemplate: '$carpetaTeselas{z}-{x}-{y}.png',
        tileProvider: AssetTileProvider(),
        maxNativeZoom: 16,
        userAgentPackageName: 'pe.bosqueseco.explorador',
      ),
    PolylineLayer(
      polylines: [
        Polyline(
          points: [for (final c in progreso.ruta.camino) _aLatLng(c)],
          color: esquema.primary,
          strokeWidth: 5,
          borderColor: esquema.surface,
          borderStrokeWidth: 2,
        ),
      ],
    ),
    MarkerLayer(
      markers: [
        for (final punto in progreso.puntos)
          if (punto.punto.ubicacion case final ubicacion?)
            Marker(
              point: _aLatLng(ubicacion),
              width: 36,
              height: 36,
              child: _MarcaPunto(
                orden: punto.orden,
                visitado: punto.visitado,
                esSiguiente: punto == siguiente,
              ),
            ),
        if (posicion != null)
          Marker(
            point: _aLatLng(posicion),
            width: 28,
            height: 28,
            child: Tooltip(
              message: l10n.mapaTuUbicacion,
              child: const _MarcaTurista(),
            ),
          ),
      ],
    ),
    const Scalebar(alignment: Alignment.bottomLeft),
    if (hayTeselas)
      const Align(alignment: Alignment.bottomRight, child: _Atribucion()),
  ];
}

/// Botón redondo para recentrar la cámara en toda la ruta.
Widget _botonCentrar(BuildContext context, VoidCallback onPressed) =>
    IconButton.filledTonal(
      tooltip: context.l10n.mapaCentrar,
      onPressed: onPressed,
      icon: const Icon(Icons.fit_screen_outlined),
    );

/// Mapa de la ruta que funciona sin señal: el camino, los puntos con su
/// estado y la posición GPS del turista.
///
/// Dentro de la lista solo responde al zoom con dos dedos, para que el
/// arrastre con un dedo haga scroll de la página. Para navegarlo con un
/// dedo, se abre en pantalla completa.
class MapaRuta extends ConsumerStatefulWidget {
  const MapaRuta({required this.progreso, super.key});

  final ProgresoRuta progreso;

  @override
  ConsumerState<MapaRuta> createState() => _MapaRutaState();
}

class _MapaRutaState extends ConsumerState<MapaRuta> {
  final _controlador = MapController();

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _abrirPantallaCompleta() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _MapaPantallaCompleta(progreso: widget.progreso),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progreso = widget.progreso;
    final hayTeselas = ref.watch(hayTeselasProvider).value ?? false;
    final posicion = ref.watch(ubicacionViewModelProvider).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: l10n.mapaDescripcion(progreso.total),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppEspacios.radio),
            child: SizedBox(
              height: 320,
              child: FlutterMap(
                mapController: _controlador,
                options: MapOptions(
                  initialCameraFit: _ajusteRuta(progreso),
                  backgroundColor: context.colores.mapa,
                  minZoom: 10,
                  maxZoom: 18,
                  // Solo gestos con dos dedos: así el arrastre con un dedo
                  // hace scroll de la lista en vez de mover el mapa.
                  interactionOptions: const InteractionOptions(
                    flags:
                        InteractiveFlag.pinchZoom |
                        InteractiveFlag.pinchMove |
                        InteractiveFlag.doubleTapZoom,
                  ),
                ),
                children: [
                  ..._capasRuta(
                    context,
                    progreso: progreso,
                    hayTeselas: hayTeselas,
                    posicion: posicion,
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(AppEspacios.s),
                      child: Column(
                        children: [
                          IconButton.filledTonal(
                            tooltip: l10n.mapaPantallaCompleta,
                            onPressed: _abrirPantallaCompleta,
                            icon: const Icon(Icons.fullscreen),
                          ),
                          const SizedBox(height: AppEspacios.s),
                          _botonCentrar(
                            context,
                            () => _controlador.fitCamera(_ajusteRuta(progreso)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppEspacios.s),
        Text(
          l10n.mapaMoverAyuda,
          style: context.textos.bodySmall?.copyWith(
            color: context.esquema.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppEspacios.xs),
        _EstadoGps(progreso: progreso),
      ],
    );
  }
}

/// La ruta a pantalla completa, donde se navega con un dedo sin pelear con
/// el scroll de la página. El botón de volver la cierra.
class _MapaPantallaCompleta extends ConsumerStatefulWidget {
  const _MapaPantallaCompleta({required this.progreso});

  final ProgresoRuta progreso;

  @override
  ConsumerState<_MapaPantallaCompleta> createState() =>
      _MapaPantallaCompletaState();
}

class _MapaPantallaCompletaState extends ConsumerState<_MapaPantallaCompleta> {
  final _controlador = MapController();

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progreso = widget.progreso;
    final hayTeselas = ref.watch(hayTeselasProvider).value ?? false;
    final posicion = ref.watch(ubicacionViewModelProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text(progreso.ruta.nombre)),
      body: Semantics(
        label: l10n.mapaDescripcion(progreso.total),
        child: FlutterMap(
          mapController: _controlador,
          options: MapOptions(
            initialCameraFit: _ajusteRuta(progreso),
            backgroundColor: context.colores.mapa,
            minZoom: 10,
            maxZoom: 18,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            ..._capasRuta(
              context,
              progreso: progreso,
              hayTeselas: hayTeselas,
              posicion: posicion,
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppEspacios.s),
                child: _botonCentrar(
                  context,
                  () => _controlador.fitCamera(_ajusteRuta(progreso)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Punto de la ruta con su número: relleno si ya tiene sello y resaltado si
/// es el siguiente.
class _MarcaPunto extends StatelessWidget {
  const _MarcaPunto({
    required this.orden,
    required this.visitado,
    required this.esSiguiente,
  });

  final int orden;
  final bool visitado;
  final bool esSiguiente;

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquema;
    final (fondo, frente) = esSiguiente
        ? (esquema.secondary, esquema.onSecondary)
        : visitado
        ? (esquema.primary, esquema.onPrimary)
        : (esquema.surface, esquema.onSurface);

    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fondo,
          shape: BoxShape.circle,
          border: Border.all(color: esquema.primary, width: 3),
        ),
        child: Center(
          child: visitado && !esSiguiente
              ? Icon(Icons.check, size: 18, color: frente)
              : Text(
                  '$orden',
                  style: context.textos.labelLarge?.copyWith(color: frente),
                  textScaler: TextScaler.noScaling,
                ),
        ),
      ),
    );
  }
}

/// "Estás aquí": punto azul como en cualquier mapa.
class _MarcaTurista extends StatelessWidget {
  const _MarcaTurista();

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquema;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: esquema.tertiary,
        shape: BoxShape.circle,
        border: Border.all(color: esquema.surface, width: 4),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Color(0x55000000))],
      ),
    );
  }
}

/// Las teselas de OpenStreetMap exigen citar la fuente.
class _Atribucion extends StatelessWidget {
  const _Atribucion();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.esquema.surface.withValues(alpha: 0.8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          '© OpenStreetMap',
          style: context.textos.labelSmall?.copyWith(
            color: context.esquema.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Qué dice el GPS: cuánto falta al siguiente punto, o cómo activarlo.
class _EstadoGps extends ConsumerWidget {
  const _EstadoGps({required this.progreso});

  final ProgresoRuta progreso;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ubicacion = ref.watch(ubicacionViewModelProvider);

    final posicion = ubicacion.value;
    final (IconData icono, String texto) = switch (ubicacion.error) {
      _ when posicion != null => _textoPosicion(l10n, posicion),
      UbicacionNoDisponible(problema: ProblemaUbicacion.sinPermiso) => (
        Icons.location_disabled_outlined,
        l10n.mapaGpsSinPermiso,
      ),
      Object() => (Icons.location_disabled_outlined, l10n.mapaGpsApagado),
      null => (Icons.gps_not_fixed, l10n.mapaGpsBuscando),
    };

    return Semantics(
      liveRegion: true,
      child: Row(
        children: [
          Icon(icono, size: 20, color: context.esquema.primary),
          const SizedBox(width: AppEspacios.s),
          Expanded(child: Text(texto, style: context.textos.bodyMedium)),
        ],
      ),
    );
  }

  (IconData, String) _textoPosicion(AppLocalizations l10n, Coordenada aqui) {
    String metros(int m) => formatearDistancia(m, l10n.localeName);
    if (progreso.fueraDeRuta(aqui)) {
      final masCerca = [
        for (final p in progreso.puntos) ?p.punto.ubicacion?.distanciaA(aqui),
      ].reduce((a, b) => a < b ? a : b);
      return (
        Icons.near_me_outlined,
        l10n.mapaGpsFueraDeRuta(metros(masCerca)),
      );
    }
    final alSiguiente = progreso.metrosAlSiguiente(aqui);
    if (alSiguiente == null) return (Icons.my_location, l10n.mapaGpsEnRuta);
    return (Icons.my_location, l10n.mapaGpsAlSiguiente(metros(alSiguiente)));
  }
}
