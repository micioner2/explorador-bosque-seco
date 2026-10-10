import 'package:explorador_bosque_seco/features/puntos/domain/escaneo.dart';
import 'package:explorador_bosque_seco/features/puntos/domain/pasaporte.dart';
import 'package:explorador_bosque_seco/features/puntos/domain/producto.dart';
import 'package:flutter_test/flutter_test.dart';

Escaneo escaneo(
  String id,
  String puntoId, {
  String visitaId = 'v1',
  EstadoEscaneo estado = EstadoEscaneo.pendiente,
}) => Escaneo(
  id: id,
  visitaId: visitaId,
  puntoId: puntoId,
  fecha: DateTime(2026, 10, 10, 9),
  estado: estado,
);

Pasaporte registrarOFallar(Pasaporte pasaporte, Escaneo nuevo) {
  final resultado = pasaporte.registrar(nuevo);
  if (resultado is PuntoGanado) return resultado.pasaporte;
  fail('Se esperaba ganar un punto con ${nuevo.puntoId}');
}

void main() {
  final polo = Producto(
    id: 'polo',
    nombre: 'Polo',
    puntosRequeridos: 3,
    porcentajeDescuento: 15,
  );

  group('Registrar escaneos', () {
    test('un punto nuevo suma un punto pendiente', () {
      final pasaporte = registrarOFallar(Pasaporte(), escaneo('e1', 'pozas'));

      expect(pasaporte.puntosPendientes, 1);
      expect(pasaporte.puntosConfirmados, 0);
    });

    test('escanear el mismo punto dos veces no suma de nuevo', () {
      final pasaporte = registrarOFallar(Pasaporte(), escaneo('e1', 'pozas'));

      final resultado = pasaporte.registrar(escaneo('e2', 'pozas'));

      expect(resultado, isA<PuntoYaRegistrado>());
    });

    test('el mismo punto en otra visita sí suma', () {
      final primera = registrarOFallar(Pasaporte(), escaneo('e1', 'pozas'));

      final resultado = primera.registrar(
        escaneo('e2', 'pozas', visitaId: 'v2'),
      );

      expect(resultado, isA<PuntoGanado>());
    });

    test('los duplicados que llegan por sincronización no cuentan', () {
      final pasaporte = Pasaporte(
        escaneos: [
          escaneo('e1', 'pozas', estado: EstadoEscaneo.confirmado),
          escaneo('e2', 'pozas', estado: EstadoEscaneo.confirmado),
        ],
      );

      expect(pasaporte.sellos, hasLength(1));
      expect(pasaporte.puntosConfirmados, 1);
    });
  });

  group('Confirmar al sincronizar', () {
    test('solo se confirman los escaneos aceptados por el servidor', () {
      final pasaporte = Pasaporte(
        escaneos: [escaneo('e1', 'pozas'), escaneo('e2', 'caida')],
      ).confirmar({'e1'});

      expect(pasaporte.puntosConfirmados, 1);
      expect(pasaporte.puntosPendientes, 1);
    });
  });

  group('Canjear', () {
    Pasaporte conConfirmados(int cantidad) => Pasaporte(
      escaneos: [
        for (var i = 0; i < cantidad; i++)
          escaneo('e$i', 'punto$i', estado: EstadoEscaneo.confirmado),
      ],
    );

    test('con puntos suficientes descuenta los puntos usados', () {
      final pasaporte = conConfirmados(4).canjear(polo);

      expect(pasaporte.puntosDisponibles, 1);
    });

    test('sin puntos suficientes lanza CanjeInvalido', () {
      expect(
        () => conConfirmados(2).canjear(polo),
        throwsA(isA<CanjeInvalido>()),
      );
    });

    test('los puntos pendientes no se pueden canjear', () {
      final pasaporte = Pasaporte(
        escaneos: [
          escaneo('e1', 'a', estado: EstadoEscaneo.confirmado),
          escaneo('e2', 'b'),
          escaneo('e3', 'c'),
        ],
      );

      expect(pasaporte.puedeCanjear(polo), isFalse);
      expect(pasaporte.puntosFaltantes(polo), 2);
    });

    test('no se puede canjear dos veces con los mismos puntos', () {
      final despues = conConfirmados(3).canjear(polo);

      expect(despues.puedeCanjear(polo), isFalse);
    });
  });

  group('Producto', () {
    test('rechaza puntos requeridos en cero', () {
      expect(
        () => Producto(
          id: 'x',
          nombre: 'X',
          puntosRequeridos: 0,
          porcentajeDescuento: 10,
        ),
        throwsArgumentError,
      );
    });

    test('rechaza descuentos mayores a 100%', () {
      expect(
        () => Producto(
          id: 'x',
          nombre: 'X',
          puntosRequeridos: 1,
          porcentajeDescuento: 120,
        ),
        throwsArgumentError,
      );
    });
  });
}
