import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/coordenada.dart';
import '../domain/ruta.dart';
import '../domain/ruta_repository.dart';

/// Ruta de demostración de El Angolo. Las distancias, los tiempos y las
/// coordenadas son valores de ejemplo cerca del puesto de control: se
/// reemplazan con el trazado GPS real de la asociación.
class RutaRepositoryDemo implements RutaRepository {
  const RutaRepositoryDemo();

  @override
  Ruta rutaActual() => Ruta(
    id: 'pozas',
    nombre: 'Ruta de las Pozas',
    puntos: [
      PuntoRuta(
        id: 'entrada',
        nombre: 'Puesto de control',
        ubicacion: const Coordenada(-4.3000, -80.8600),
      ),
      PuntoRuta(
        id: 'pozas',
        nombre: 'Pozas de agua',
        metrosDesdeAnterior: 1500,
        minutosDesdeAnterior: 35,
        ubicacion: const Coordenada(-4.2940, -80.8510),
      ),
      PuntoRuta(
        id: 'caida',
        nombre: 'Caída de agua',
        metrosDesdeAnterior: 1200,
        minutosDesdeAnterior: 25,
        ubicacion: const Coordenada(-4.2865, -80.8465),
      ),
      PuntoRuta(
        id: 'mirador',
        nombre: 'Mirador',
        metrosDesdeAnterior: 850,
        minutosDesdeAnterior: 20,
        ubicacion: const Coordenada(-4.2835, -80.8520),
      ),
      PuntoRuta(
        id: 'venados',
        nombre: 'Avistamiento de venados',
        metrosDesdeAnterior: 1050,
        minutosDesdeAnterior: 30,
        ubicacion: const Coordenada(-4.2875, -80.8585),
      ),
    ],
    // Sendero con sus curvas, como lo marcaría un GPS.
    trazado: const [
      Coordenada(-4.3000, -80.8600),
      Coordenada(-4.2992, -80.8578),
      Coordenada(-4.2971, -80.8566),
      Coordenada(-4.2962, -80.8541),
      Coordenada(-4.2948, -80.8529),
      Coordenada(-4.2940, -80.8510),
      Coordenada(-4.2921, -80.8502),
      Coordenada(-4.2903, -80.8481),
      Coordenada(-4.2884, -80.8478),
      Coordenada(-4.2865, -80.8465),
      Coordenada(-4.2851, -80.8479),
      Coordenada(-4.2846, -80.8501),
      Coordenada(-4.2835, -80.8520),
      Coordenada(-4.2848, -80.8541),
      Coordenada(-4.2853, -80.8566),
      Coordenada(-4.2875, -80.8585),
    ],
  );
}

/// Punto único donde se elige la implementación del repositorio.
final rutaRepositoryProvider = Provider<RutaRepository>(
  (ref) => const RutaRepositoryDemo(),
);
