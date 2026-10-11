import 'package:explorador_bosque_seco/features/mapa/data/ruta_repository_demo.dart';
import 'package:explorador_bosque_seco/features/mapa/domain/coordenada.dart';
import 'package:explorador_bosque_seco/features/mapa/domain/progreso_ruta.dart';
import 'package:explorador_bosque_seco/features/mapa/domain/ruta.dart';
import 'package:explorador_bosque_seco/features/puntos/domain/escaneo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('distancia', () {
    test('un minuto de latitud mide cerca de 1,85 km', () {
      const a = Coordenada(-4.30, -80.86);
      const b = Coordenada(-4.30 + 1 / 60, -80.86);

      expect(a.distanciaA(b), closeTo(1853, 5));
    });

    test('la distancia a uno mismo es cero', () {
      const a = Coordenada(-4.30, -80.86);

      expect(a.distanciaA(a), 0);
    });
  });

  group('ruta en el mapa', () {
    final ruta = const RutaRepositoryDemo().rutaActual();

    test('la ruta de demostración tiene todos sus puntos ubicados', () {
      expect(ruta.georreferenciada, isTrue);
      expect(ruta.camino.first, ruta.puntos.first.ubicacion);
      expect(ruta.camino.last, ruta.puntos.last.ubicacion);
    });

    test('sin trazado, el camino une los puntos en orden', () {
      final simple = Ruta(
        id: 'r',
        nombre: 'Ruta',
        puntos: [
          PuntoRuta(id: 'a', nombre: 'A', ubicacion: const Coordenada(0, 0)),
          PuntoRuta(id: 'b', nombre: 'B', ubicacion: const Coordenada(0, 1)),
        ],
      );

      expect(simple.camino, const [Coordenada(0, 0), Coordenada(0, 1)]);
    });

    test('una ruta sin coordenadas no se dibuja en el mapa', () {
      final sinGps = Ruta(
        id: 'r',
        nombre: 'Ruta',
        puntos: [PuntoRuta(id: 'a', nombre: 'A')],
      );

      expect(sinGps.georreferenciada, isFalse);
    });
  });

  group('posición del turista', () {
    final ruta = const RutaRepositoryDemo().rutaActual();
    final progreso = ProgresoRuta.calcular(ruta, [
      Escaneo(
        id: 'e1',
        visitaId: 'v1',
        puntoId: 'entrada',
        fecha: DateTime(2026, 10, 10, 8),
      ),
    ]);

    test('mide la distancia al siguiente punto sin sello', () {
      final pozas = ruta.puntos[1].ubicacion!;

      expect(progreso.siguiente?.punto.id, 'pozas');
      expect(progreso.metrosAlSiguiente(pozas), 0);
      expect(progreso.fueraDeRuta(pozas), isFalse);
    });

    test('desde la ciudad de Piura está fuera de la ruta', () {
      const piura = Coordenada(-5.1945, -80.6328);

      expect(progreso.fueraDeRuta(piura), isTrue);
    });
  });
}
