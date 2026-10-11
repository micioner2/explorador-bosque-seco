import 'package:explorador_bosque_seco/features/mapa/domain/ruta.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Ruta rutaDePrueba() => Ruta(
    id: 'r1',
    nombre: 'Ruta de prueba',
    puntos: [
      PuntoRuta(id: 'entrada', nombre: 'Entrada'),
      PuntoRuta(
        id: 'pozas',
        nombre: 'Pozas',
        metrosDesdeAnterior: 1500,
        minutosDesdeAnterior: 35,
      ),
      PuntoRuta(
        id: 'mirador',
        nombre: 'Mirador',
        metrosDesdeAnterior: 850,
        minutosDesdeAnterior: 20,
      ),
    ],
  );

  test('la distancia y el tiempo totales suman todos los tramos', () {
    final ruta = rutaDePrueba();

    expect(ruta.metrosTotales, 2350);
    expect(ruta.duracionTotal, const Duration(minutes: 55));
  });

  test('una ruta necesita al menos un punto', () {
    expect(
      () => Ruta(id: 'r1', nombre: 'Vacía', puntos: const []),
      throwsArgumentError,
    );
  });

  test('una ruta no acepta el mismo punto dos veces', () {
    expect(
      () => Ruta(
        id: 'r1',
        nombre: 'Repetida',
        puntos: [
          PuntoRuta(id: 'pozas', nombre: 'Pozas'),
          PuntoRuta(id: 'pozas', nombre: 'Pozas otra vez'),
        ],
      ),
      throwsArgumentError,
    );
  });

  test('un tramo no puede tener distancia ni tiempo negativos', () {
    expect(
      () => PuntoRuta(id: 'p', nombre: 'P', metrosDesdeAnterior: -1),
      throwsArgumentError,
    );
    expect(
      () => PuntoRuta(id: 'p', nombre: 'P', minutosDesdeAnterior: -1),
      throwsArgumentError,
    );
  });

  test('los puntos de la ruta no se pueden modificar desde fuera', () {
    final ruta = rutaDePrueba();

    expect(
      () => ruta.puntos.add(PuntoRuta(id: 'x', nombre: 'X')),
      throwsUnsupportedError,
    );
  });
}
