import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../escaneo/presentation/view_models/escaneo_view_model.dart';
import '../../../preferencias/domain/preferencias.dart';
import '../../../preferencias/presentation/view_models/preferencias_view_model.dart';
import '../../../puntos/presentation/view_models/pasaporte_view_model.dart';
import '../../data/ruta_repository_demo.dart';
import '../../data/ubicacion_repository_gps.dart';
import '../../domain/coordenada.dart';
import '../../domain/progreso_ruta.dart';
import '../../domain/ruta.dart';
import '../../domain/ubicacion_repository.dart';

/// Ruta que se muestra: la del bosque o la de la sede de la demo, según
/// Ajustes.
final rutaActualProvider = Provider<Ruta>((ref) {
  final repositorio = ref.watch(rutaRepositoryProvider);
  final (elegida, centro) = ref.watch(
    preferenciasViewModelProvider.select((p) => (p.rutaDemo, p.centroSede)),
  );
  return switch (elegida) {
    RutaDemo.angolo => repositorio.rutaActual(),
    RutaDemo.sede => repositorio.rutaDeLaSede(centro),
  };
});

/// Estado de la pantalla Mapa: la ruta y el avance del grupo vinculado en
/// ella (sin grupo, ningún punto visitado). Se recalcula cada vez que el
/// pasaporte gana o confirma un sello.
final mapaViewModelProvider = Provider<ProgresoRuta>((ref) {
  final grupo = ref.watch(vinculoViewModelProvider);
  return ProgresoRuta.calcular(
    ref.watch(rutaActualProvider),
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

/// Toma la posición GPS actual y arma ahí la ruta de la sede (Ajustes).
/// Devuelve `false` si el GPS no respondió a tiempo o no tiene permiso.
final centrarRutaAquiProvider = Provider<Future<bool> Function()>(
  (ref) => () async {
    try {
      final aqui = await ref
          .read(ubicacionRepositoryProvider)
          .posiciones()
          .first
          .timeout(const Duration(seconds: 20));
      await ref
          .read(preferenciasViewModelProvider.notifier)
          .centrarSedeEn(aqui);
      return true;
    } on Object {
      return false;
    }
  },
);
