import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/ruta.dart';
import '../domain/ruta_repository.dart';

/// Ruta de demostración de El Angolo. Las distancias y los tiempos son
/// valores de ejemplo: se reemplazan con el trazado real de la asociación.
class RutaRepositoryDemo implements RutaRepository {
  const RutaRepositoryDemo();

  @override
  Ruta rutaActual() => Ruta(
    id: 'pozas',
    nombre: 'Ruta de las Pozas',
    puntos: [
      PuntoRuta(id: 'entrada', nombre: 'Puesto de control'),
      PuntoRuta(
        id: 'pozas',
        nombre: 'Pozas de agua',
        metrosDesdeAnterior: 1500,
        minutosDesdeAnterior: 35,
      ),
      PuntoRuta(
        id: 'caida',
        nombre: 'Caída de agua',
        metrosDesdeAnterior: 1200,
        minutosDesdeAnterior: 25,
      ),
      PuntoRuta(
        id: 'mirador',
        nombre: 'Mirador',
        metrosDesdeAnterior: 850,
        minutosDesdeAnterior: 20,
      ),
      PuntoRuta(
        id: 'venados',
        nombre: 'Avistamiento de venados',
        metrosDesdeAnterior: 1050,
        minutosDesdeAnterior: 30,
      ),
    ],
  );
}

/// Punto único donde se elige la implementación del repositorio.
final rutaRepositoryProvider = Provider<RutaRepository>(
  (ref) => const RutaRepositoryDemo(),
);
