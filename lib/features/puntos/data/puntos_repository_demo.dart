import '../domain/escaneo.dart';
import '../domain/pasaporte.dart';
import '../domain/producto.dart';

/// Pasaporte de demostración: dos puntos confirmados y uno pendiente de
/// sincronizar, como si el turista estuviera en el bosque sin señal.
class PuntosRepositoryDemo {
  const PuntosRepositoryDemo();

  Pasaporte pasaporte() {
    final inicio = DateTime(2026, 10, 10, 9);
    return Pasaporte(
      escaneos: [
        Escaneo(
          id: 'e1',
          visitaId: 'v-demo',
          puntoId: 'entrada',
          fecha: inicio,
          estado: EstadoEscaneo.confirmado,
        ),
        Escaneo(
          id: 'e2',
          visitaId: 'v-demo',
          puntoId: 'pozas',
          fecha: inicio.add(const Duration(minutes: 50)),
          estado: EstadoEscaneo.confirmado,
        ),
        Escaneo(
          id: 'e3',
          visitaId: 'v-demo',
          puntoId: 'caida',
          fecha: inicio.add(const Duration(minutes: 95)),
        ),
      ],
    );
  }

  /// Productos de la comunidad (valores de ejemplo).
  List<Producto> productos() => [
    Producto(
      id: 'miel',
      nombre: 'Miel de algarrobo',
      puntosRequeridos: 2,
      porcentajeDescuento: 10,
    ),
    Producto(
      id: 'polo',
      nombre: 'Polo bordado de la comunidad',
      puntosRequeridos: 5,
      porcentajeDescuento: 15,
    ),
  ];
}
