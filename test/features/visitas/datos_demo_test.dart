import 'package:explorador_bosque_seco/core/almacen/almacen_local.dart';
import 'package:explorador_bosque_seco/core/almacen/coleccion_local.dart';
import 'package:explorador_bosque_seco/core/reloj.dart';
import 'package:explorador_bosque_seco/features/puntos/presentation/views/pasaporte_page.dart';
import 'package:explorador_bosque_seco/features/reservas/presentation/view_models/reservas_view_model.dart';
import 'package:explorador_bosque_seco/features/sesion/data/sesion_repository_demo.dart';
import 'package:explorador_bosque_seco/features/sesion/presentation/view_models/sesion_view_model.dart';
import 'package:explorador_bosque_seco/features/visitas/presentation/view_models/visitas_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/app_de_prueba.dart';

/// La demo se ve igual a cualquier hora: los datos de ejemplo se calculan
/// con `relojProvider`.
void main() {
  ProviderContainer abrir(DateTime ahora, {AlmacenLocal? almacen}) {
    final container = ProviderContainer(
      overrides: [
        relojProvider.overrideWithValue(() => ahora),
        almacenLocalProvider.overrideWithValue(almacen ?? AlmacenMemoria()),
        datosDemoProvider.overrideWithValue(true),
        sesionRepositoryProvider.overrideWithValue(
          SesionRepositoryDemo(cuentaGuardada: SesionRepositoryDemo.cuentaDemo),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  final horas = [
    DateTime(2026, 10, 11, 0, 15),
    DateTime(2026, 10, 11, 8),
    DateTime(2026, 10, 11, 12),
    DateTime(2026, 10, 11, 17, 45),
    DateTime(2026, 10, 11, 23, 50),
  ];

  for (final ahora in horas) {
    final hora = '${ahora.hour}:${ahora.minute.toString().padLeft(2, '0')}';

    test('a las $hora hay un grupo que debió salir hace 30 minutos', () {
      final resumen = abrir(ahora).read(resumenDelDiaProvider);

      expect(resumen.atrasadas, hasLength(1));
      expect(
        resumen.atrasadas.single.salidaPrevista,
        ahora.subtract(const Duration(minutes: 30)),
      );
      // Y otros dos dentro de su horario.
      expect(resumen.dentro, hasLength(3));
    });

    test('a las $hora hay una reserva que llega en la próxima hora', () {
      final reservas = abrir(ahora).read(reservasViewModelProvider);

      expect(
        reservas.where(
          (r) =>
              r.pendiente &&
              r.fechaHora.isAfter(ahora) &&
              r.fechaHora.difference(ahora) <= const Duration(hours: 1),
        ),
        hasLength(1),
      );
    });
  }

  test('si el guía marca la salida del grupo atrasado, la alerta se va y no '
      'vuelve al abrir de nuevo', () {
    final almacen = AlmacenMemoria();
    final ahora = DateTime(2026, 10, 11, 9);
    final app = abrir(ahora, almacen: almacen);
    app
        .read(sesionViewModelProvider.notifier)
        .elegirGuia(app.read(guiasDeLaCuentaProvider).first);
    final atrasada = app.read(resumenDelDiaProvider).atrasadas.single;

    app.read(visitasViewModelProvider.notifier).marcarSalida(atrasada.id);

    expect(app.read(resumenDelDiaProvider).atrasadas, isEmpty);
    final otraVez = abrir(
      ahora.add(const Duration(hours: 1)),
      almacen: almacen,
    );
    expect(otraVez.read(resumenDelDiaProvider).atrasadas, isEmpty);
  });

  testWidgets('sin grupo vinculado, el pasaporte invita a escanear el QR del '
      'grupo', (tester) async {
    await montarPantalla(tester, const PasaportePage(), grupo: null);

    expect(find.text('Aún no tienes sellos'), findsOneWidget);
    expect(find.text('Escanear el QR del grupo'), findsOneWidget);
    expect(find.text('Mis sellos'), findsNothing);
  });
}
