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

  /// Centro de la sede de la presentación (coordenadas que dio el equipo).
  /// En el lugar se puede cambiar desde Ajustes → "Centrar la ruta aquí".
  static const centroSede = Coordenada(-4.425429, -80.756187);

  /// Cinco puntos a pocos pasos de la sede (unos 170 m en total), en el
  /// orden en que se recorren. Mismo formato de QR que la ruta del bosque.
  @override
  Ruta rutaDeLaSede([Coordenada? centro]) {
    final c = centro ?? centroSede;
    // 1 metro ≈ 0,000009 grados cerca del ecuador.
    Coordenada a(double norte, double este) =>
        Coordenada(c.latitud + norte * 0.000009, c.longitud + este * 0.000009);

    return Ruta(
      id: 'sede',
      nombre: 'Ruta de demostración · Cámara de Comercio de Piura',
      puntos: [
        PuntoRuta(id: 'sede-entrada', nombre: 'Entrada', ubicacion: a(0, 0)),
        PuntoRuta(
          id: 'sede-norte',
          nombre: 'Esquina norte',
          metrosDesdeAnterior: 40,
          minutosDesdeAnterior: 1,
          ubicacion: a(40, 0),
        ),
        PuntoRuta(
          id: 'sede-noreste',
          nombre: 'Esquina noreste',
          metrosDesdeAnterior: 40,
          minutosDesdeAnterior: 1,
          ubicacion: a(40, 40),
        ),
        PuntoRuta(
          id: 'sede-este',
          nombre: 'Esquina este',
          metrosDesdeAnterior: 40,
          minutosDesdeAnterior: 1,
          ubicacion: a(0, 40),
        ),
        PuntoRuta(
          id: 'sede-encuentro',
          nombre: 'Punto de encuentro',
          metrosDesdeAnterior: 50,
          minutosDesdeAnterior: 1,
          ubicacion: a(-30, 20),
        ),
      ],
    );
  }
}

/// Punto único donde se elige la implementación del repositorio.
final rutaRepositoryProvider = Provider<RutaRepository>(
  (ref) => const RutaRepositoryDemo(),
);
