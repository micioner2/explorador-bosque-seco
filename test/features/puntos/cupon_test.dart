import 'package:explorador_bosque_seco/core/almacen/almacen_local.dart';
import 'package:explorador_bosque_seco/core/almacen/coleccion_local.dart';
import 'package:explorador_bosque_seco/core/reloj.dart';
import 'package:explorador_bosque_seco/features/escaneo/domain/lectura_qr.dart';
import 'package:explorador_bosque_seco/features/puntos/domain/cupon.dart';
import 'package:explorador_bosque_seco/features/puntos/presentation/view_models/pasaporte_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cupon = Cupon(
    id: 'c-1',
    productoId: 'miel',
    nombreProducto: 'Miel de algarrobo',
    porcentajeDescuento: 10,
    emitido: DateTime(2026, 10, 11, 9),
  );

  test('el QR del cupón se lee como cupón, con su producto y descuento', () {
    final lectura = LecturaQr.desde(cupon.codigoQr);

    expect(lectura, isA<QrDeCupon>());
    lectura as QrDeCupon;
    expect(lectura.id, 'c-1');
    expect(lectura.productoId, 'miel');
    expect(lectura.porcentaje, 10);
  });

  test('un cupón vale una sola vez en el puesto (R18)', () {
    final usados = CuponesUsados();

    final primera = usados.validar(
      id: 'c-1',
      productoId: 'miel',
      porcentaje: 10,
    );
    final segunda = usados
        .usar('c-1')
        .validar(id: 'c-1', productoId: 'miel', porcentaje: 10);

    expect(primera, isA<CuponValido>());
    expect(segunda, isA<CuponYaUsado>());
  });

  test('canjear entrega un cupón que queda guardado en el celular', () {
    final almacen = AlmacenMemoria();
    ProviderContainer abrir() {
      final app = ProviderContainer(
        overrides: [
          almacenLocalProvider.overrideWithValue(almacen),
          datosDemoProvider.overrideWithValue(true),
          relojProvider.overrideWithValue(() => DateTime(2026, 10, 11, 9)),
        ],
      );
      addTearDown(app.dispose);
      return app;
    }

    final app = abrir();
    final miel = app.read(productosProvider).first;
    final emitido = app.read(pasaporteViewModelProvider.notifier).canjear(miel);

    expect(emitido.productoId, miel.id);
    expect(abrir().read(cuponesViewModelProvider).single.id, emitido.id);
  });

  test('el puesto recuerda los cupones usados al volver a abrir', () {
    final almacen = AlmacenMemoria();
    ProviderContainer abrir() {
      final app = ProviderContainer(
        overrides: [almacenLocalProvider.overrideWithValue(almacen)],
      );
      addTearDown(app.dispose);
      return app;
    }

    abrir()
        .read(cuponesUsadosViewModelProvider.notifier)
        .validar(id: 'c-1', productoId: 'miel', porcentaje: 10);

    expect(
      abrir()
          .read(cuponesUsadosViewModelProvider.notifier)
          .validar(id: 'c-1', productoId: 'miel', porcentaje: 10),
      isA<CuponYaUsado>(),
    );
  });
}
