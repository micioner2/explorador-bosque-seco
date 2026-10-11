import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../escaneo/presentation/view_models/escaneo_view_model.dart';
import '../../../puntos/presentation/view_models/pasaporte_view_model.dart';
import '../../data/ruta_repository_demo.dart';
import '../../data/ubicacion_repository_gps.dart';
import '../../domain/coordenada.dart';
import '../../domain/progreso_ruta.dart';
import '../../domain/ubicacion_repository.dart';

/// Estado de la pantalla Mapa: la ruta y el avance del grupo vinculado en
/// ella (sin grupo, ningún punto visitado). Se recalcula cada vez que el
/// pasaporte gana o confirma un sello.
final mapaViewModelProvider = Provider<ProgresoRuta>((ref) {
  final grupo = ref.watch(vinculoViewModelProvider);
  return ProgresoRuta.calcular(
    ref.watch(rutaRepositoryProvider).rutaActual(),
    ref
        .watch(pasaporteViewModelProvider)
        .sellos
        .where((sello) => sello.visitaId == grupo),
  );
});

/// Posición GPS del turista mientras el mapa está abierto. Al salir del
/// mapa se apaga el GPS para cuidar la batería.
///
/// Si el GPS está apagado o sin permiso no se reintenta solo: la pantalla
/// explica qué hacer y se vuelve a intentar al volver a abrir el mapa.
final ubicacionViewModelProvider = StreamProvider.autoDispose<Coordenada>(
  (ref) => ref.watch(ubicacionRepositoryProvider).posiciones(),
  retry: (intento, error) => error is UbicacionNoDisponible
      ? null
      : Duration(seconds: 2 * (intento + 1)),
);

/// Carpeta de las teselas del mapa base dentro de la app (se descargan con
/// `tool/descargar_teselas.py`). Nombre de cada archivo: `z-x-y.png`.
const carpetaTeselas = 'assets/teselas/';

/// Si la app trae las teselas del mapa base. Sin ellas, el mapa muestra la
/// ruta, los puntos y el GPS sobre un fondo liso.
final hayTeselasProvider = FutureProvider<bool>((ref) async {
  final manifiesto = await AssetManifest.loadFromAssetBundle(rootBundle);
  return manifiesto.listAssets().any(
    (asset) => asset.startsWith(carpetaTeselas) && asset.endsWith('.png'),
  );
});
