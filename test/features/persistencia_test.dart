import 'package:explorador_bosque_seco/core/almacen/almacen_local.dart';
import 'package:explorador_bosque_seco/core/almacen/coleccion_local.dart';
import 'package:explorador_bosque_seco/core/reloj.dart';
import 'package:explorador_bosque_seco/features/puntos/presentation/view_models/pasaporte_view_model.dart';
import 'package:explorador_bosque_seco/features/reservas/presentation/view_models/reservas_view_model.dart';
import 'package:explorador_bosque_seco/features/sesion/data/sesion_repository_demo.dart';
import 'package:explorador_bosque_seco/features/sesion/presentation/view_models/sesion_view_model.dart';
import 'package:explorador_bosque_seco/features/visitas/domain/visita.dart';
import 'package:explorador_bosque_seco/features/visitas/presentation/view_models/visitas_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lo registrado en el celular sobrevive a cerrar y volver a abrir la app
/// (un `ProviderContainer` nuevo sobre el mismo almacén), sin señal.
void main() {
  final ahora = DateTime(2026, 10, 10, 9);

  ProviderContainer abrirApp(AlmacenLocal almacen, {bool demo = false}) {
    final container = ProviderContainer(
      overrides: [
        almacenLocalProvider.overrideWithValue(almacen),
        datosDemoProvider.overrideWithValue(demo),
        relojProvider.overrideWithValue(() => ahora),
        sesionRepositoryProvider.overrideWithValue(
          SesionRepositoryDemo(cuentaGuardada: SesionRepositoryDemo.cuentaDemo),
        ),
      ],
    );
    addTearDown(container.dispose);
    container
        .read(sesionViewModelProvider.notifier)
        .elegirGuia(container.read(guiasDeLaCuentaProvider).first);
    return container;
  }

  Visitante rosa() => Visitante(
    nombre: 'Rosa Castillo',
    documento: '45120300',
    edad: 41,
    procedencia: Procedencia.piura,
  );

  test('con cuentas reales, el celular empieza sin datos', () {
    final app = abrirApp(AlmacenMemoria());

    expect(app.read(visitasViewModelProvider), isEmpty);
    expect(app.read(reservasViewModelProvider), isEmpty);
    expect(app.read(pasaporteViewModelProvider).escaneos, isEmpty);
  });

  test('con la cuenta de prueba, empieza con los datos de demostración', () {
    final app = abrirApp(AlmacenMemoria(), demo: true);

    expect(app.read(visitasViewModelProvider), hasLength(3));
    expect(app.read(reservasViewModelProvider), isNotEmpty);
    expect(app.read(pasaporteViewModelProvider).escaneos, hasLength(3));
  });

  test('las visitas registradas y su salida siguen al volver a abrir', () {
    final almacen = AlmacenMemoria();
    final antes = abrirApp(almacen);
    final visita = antes
        .read(visitasViewModelProvider.notifier)
        .registrar(integrantes: [rosa()], actividades: [Actividad.aves]);
    antes.read(visitasViewModelProvider.notifier).marcarSalida(visita.id);

    final despues = abrirApp(almacen);
    final guardada = despues.read(visitasViewModelProvider).single;

    expect(guardada.id, visita.id);
    expect(guardada.responsable.documento, '45120300');
    expect(guardada.actividades, {Actividad.aves});
    expect(guardada.nombreGuia, isNotNull);
    expect(guardada.salio, isTrue);
  });

  test('las reservas y sus cambios siguen al volver a abrir', () {
    final almacen = AlmacenMemoria();
    final antes = abrirApp(almacen);
    final reserva = antes
        .read(reservasViewModelProvider.notifier)
        .crear(
          nombreContacto: 'Paola Ríos',
          telefono: '987 654 321',
          fechaHora: ahora.add(const Duration(days: 1)),
          personas: 4,
        );
    antes.read(reservasViewModelProvider.notifier).cancelar(reserva.id);

    final despues = abrirApp(almacen);
    final guardada = despues.read(reservasViewModelProvider).single;

    expect(guardada.nombreContacto, 'Paola Ríos');
    expect(guardada.personas, 4);
    expect(guardada.pendiente, isFalse);
  });

  test('los sellos del pasaporte siguen al volver a abrir', () {
    final almacen = AlmacenMemoria();
    final antes = abrirApp(almacen);
    antes
        .read(pasaporteViewModelProvider.notifier)
        .registrarEscaneo(visitaId: 'v7', puntoId: 'mirador');

    final despues = abrirApp(almacen);
    final pasaporte = despues.read(pasaporteViewModelProvider);

    expect(pasaporte.sellos.single.puntoId, 'mirador');
    expect(pasaporte.puntosPendientes, 1);
  });

  test('si lo guardado está dañado, la app abre igual', () {
    final almacen = AlmacenMemoria({
      'visitas': '{no es json',
      'turista.pasaporte': '[]',
    });

    final app = abrirApp(almacen);

    expect(app.read(visitasViewModelProvider), isEmpty);
    expect(app.read(pasaporteViewModelProvider).escaneos, isEmpty);
  });
}
