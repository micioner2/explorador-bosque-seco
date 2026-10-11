import 'package:explorador_bosque_seco/features/mapa/domain/progreso_ruta.dart';
import 'package:explorador_bosque_seco/features/mapa/domain/ruta.dart';
import 'package:explorador_bosque_seco/features/puntos/domain/escaneo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ruta = Ruta(
    id: 'r1',
    nombre: 'Ruta de prueba',
    puntos: [
      PuntoRuta(id: 'entrada', nombre: 'Entrada'),
      PuntoRuta(id: 'pozas', nombre: 'Pozas', metrosDesdeAnterior: 1500),
      PuntoRuta(id: 'mirador', nombre: 'Mirador', metrosDesdeAnterior: 850),
    ],
  );

  Escaneo sello(
    String puntoId, {
    bool confirmado = false,
    String visitaId = 'v1',
  }) => Escaneo(
    id: '$visitaId-$puntoId',
    visitaId: visitaId,
    puntoId: puntoId,
    fecha: DateTime(2026, 10, 10, 9),
    estado: confirmado ? EstadoEscaneo.confirmado : EstadoEscaneo.pendiente,
  );

  test('sin sellos, el siguiente punto es el primero de la ruta', () {
    final progreso = ProgresoRuta.calcular(ruta, const []);

    expect(progreso.visitados, 0);
    expect(progreso.total, 3);
    expect(progreso.completada, isFalse);
    expect(progreso.siguiente?.punto.id, 'entrada');
    expect(progreso.siguiente?.orden, 1);
  });

  test('el siguiente punto es el primero sin sello en el orden de la ruta', () {
    final progreso = ProgresoRuta.calcular(ruta, [
      sello('entrada', confirmado: true),
      sello('mirador'),
    ]);

    expect(progreso.visitados, 2);
    expect(progreso.siguiente?.punto.id, 'pozas');
    expect(progreso.siguiente?.orden, 2);
  });

  test('distingue sellos confirmados de pendientes de sincronizar', () {
    final progreso = ProgresoRuta.calcular(ruta, [
      sello('entrada', confirmado: true),
      sello('pozas'),
    ]);

    expect(progreso.puntos.map((punto) => punto.estado), [
      EstadoPunto.confirmado,
      EstadoPunto.pendiente,
      EstadoPunto.porVisitar,
    ]);
  });

  test('un punto queda confirmado si alguno de sus sellos se sincronizó', () {
    final progreso = ProgresoRuta.calcular(ruta, [
      sello('pozas', visitaId: 'v1'),
      sello('pozas', visitaId: 'v2', confirmado: true),
      sello('pozas', visitaId: 'v3'),
    ]);

    expect(progreso.puntos[1].estado, EstadoPunto.confirmado);
    expect(progreso.visitados, 1);
  });

  test('con todos los puntos visitados la ruta está completa', () {
    final progreso = ProgresoRuta.calcular(ruta, [
      sello('entrada'),
      sello('pozas'),
      sello('mirador'),
    ]);

    expect(progreso.completada, isTrue);
    expect(progreso.siguiente, isNull);
  });

  test('ignora sellos de puntos que no son de esta ruta', () {
    final progreso = ProgresoRuta.calcular(ruta, [sello('otro-espacio')]);

    expect(progreso.visitados, 0);
  });
}
