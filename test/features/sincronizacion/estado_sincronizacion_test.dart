import 'dart:async';

import 'package:explorador_bosque_seco/core/almacen/almacen_local.dart';
import 'package:explorador_bosque_seco/core/almacen/coleccion_local.dart';
import 'package:explorador_bosque_seco/core/reloj.dart';
import 'package:explorador_bosque_seco/features/puntos/presentation/view_models/pasaporte_view_model.dart';
import 'package:explorador_bosque_seco/features/sesion/data/sesion_repository_demo.dart';
import 'package:explorador_bosque_seco/features/sincronizacion/data/red_repository_conectividad.dart';
import 'package:explorador_bosque_seco/features/sincronizacion/domain/estado_sincronizacion.dart';
import 'package:explorador_bosque_seco/features/sincronizacion/domain/red_repository.dart';
import 'package:explorador_bosque_seco/features/sincronizacion/presentation/view_models/sincronizacion_view_model.dart';
import 'package:explorador_bosque_seco/features/sincronizacion/presentation/views/aviso_conexion.dart';
import 'package:explorador_bosque_seco/features/visitas/presentation/view_models/visitas_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/app_de_prueba.dart';

/// Red que la prueba enciende y apaga, como el modo avión.
class _RedManual implements RedRepository {
  final _cambios = StreamController<bool>.broadcast();

  void cambiar({required bool conSenal}) => _cambios.add(conSenal);

  @override
  Stream<bool> hayRed() => _cambios.stream;
}

void main() {
  group('regla', () {
    test('sin señal, todo queda guardado y se dice cuánto falta', () {
      final estado = EstadoSincronizacion.calcular(
        hayRed: false,
        pendientes: 3,
      );

      expect(estado, isA<SinSenal>());
      expect((estado as SinSenal).pendientes, 3);
    });

    test('mientras el celular no responde se asume que no hay señal', () {
      expect(
        EstadoSincronizacion.calcular(hayRed: null, pendientes: 0),
        isA<SinSenal>(),
      );
    });

    test('con señal y pendientes, quedan por sincronizar', () {
      final estado = EstadoSincronizacion.calcular(hayRed: true, pendientes: 2);

      expect((estado as ConSenal).pendientes, 2);
    });

    test('con señal y nada pendiente, todo está sincronizado', () {
      expect(
        EstadoSincronizacion.calcular(hayRed: true, pendientes: 0),
        isA<TodoSincronizado>(),
      );
    });
  });

  group('ViewModel', () {
    late _RedManual red;
    late ProviderContainer app;

    setUp(() {
      red = _RedManual();
      app = ProviderContainer(
        overrides: [
          relojProvider.overrideWithValue(() => DateTime(2026, 10, 11, 9)),
          almacenLocalProvider.overrideWithValue(AlmacenMemoria()),
          datosDemoProvider.overrideWithValue(true),
          sesionRepositoryProvider.overrideWithValue(
            SesionRepositoryDemo(
              cuentaGuardada: SesionRepositoryDemo.cuentaDemo,
            ),
          ),
          redRepositoryProvider.overrideWithValue(red),
        ],
      );
      addTearDown(app.dispose);
      app.listen(estadoPuestoProvider, (_, _) {});
      app.listen(estadoTuristaProvider, (_, _) {});
    });

    test('el estado sigue a la red: modo avión y vuelta de la señal', () async {
      red.cambiar(conSenal: false);
      await Future<void>.delayed(Duration.zero);
      expect(app.read(estadoPuestoProvider), isA<SinSenal>());

      red.cambiar(conSenal: true);
      await Future<void>.delayed(Duration.zero);
      // Los tres grupos de demostración aún no llegan al servidor.
      expect((app.read(estadoPuestoProvider) as ConSenal).pendientes, 3);
    });

    test('lo que el servidor confirma deja de estar pendiente', () async {
      red.cambiar(conSenal: true);
      await Future<void>.delayed(Duration.zero);
      final ids = [for (final v in app.read(visitasViewModelProvider)) v.id];

      app
          .read(confirmadosViewModelProvider.notifier)
          .confirmar(Colecciones.visitas, ids);

      expect(app.read(estadoPuestoProvider), isA<TodoSincronizado>());
    });

    test('el turista cuenta sus sellos pendientes', () async {
      red.cambiar(conSenal: false);
      await Future<void>.delayed(Duration.zero);

      expect(
        (app.read(estadoTuristaProvider) as SinSenal).pendientes,
        app.read(pasaporteViewModelProvider).puntosPendientes,
      );
    });
  });

  testWidgets('el aviso dice el estado real, también al lector de pantalla', (
    tester,
  ) async {
    await montarPantalla(tester, const AvisoConexion(estado: ConSenal(1)));

    expect(
      find.text('Con señal · 1 pendiente por sincronizar'),
      findsOneWidget,
    );
    expect(
      tester.getSemantics(find.byType(AvisoConexion)),
      matchesSemantics(
        isLiveRegion: true,
        label: 'Con señal · 1 pendiente por sincronizar',
      ),
    );
  });
}
