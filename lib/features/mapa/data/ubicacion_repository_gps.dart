import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../domain/coordenada.dart';
import '../domain/ubicacion_repository.dart';

/// GPS del celular con `geolocator`.
class UbicacionRepositoryGps implements UbicacionRepository {
  const UbicacionRepositoryGps();

  @override
  Stream<Coordenada> posiciones() async* {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const UbicacionNoDisponible(ProblemaUbicacion.gpsApagado);
    }
    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }
    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      throw const UbicacionNoDisponible(ProblemaUbicacion.sinPermiso);
    }
    // La última posición conocida aparece al instante; bajo techo el
    // primer dato nuevo del GPS puede tardar.
    final ultima = await Geolocator.getLastKnownPosition();
    if (ultima != null) yield Coordenada(ultima.latitude, ultima.longitude);
    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(distanceFilter: 3),
    ).map((p) => Coordenada(p.latitude, p.longitude));
  }
}

final ubicacionRepositoryProvider = Provider<UbicacionRepository>(
  (ref) => const UbicacionRepositoryGps(),
);
