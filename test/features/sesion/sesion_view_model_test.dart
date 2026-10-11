import 'package:explorador_bosque_seco/core/almacen/almacen_local.dart';
import 'package:explorador_bosque_seco/features/sesion/data/sesion_repository_demo.dart';
import 'package:explorador_bosque_seco/features/sesion/presentation/view_models/sesion_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const cuenta = SesionRepositoryDemo.cuentaDemo;

  ProviderContainer crear(
    SesionRepositoryDemo repositorio, {
    AlmacenLocal? almacen,
  }) {
    final container = ProviderContainer(
      overrides: [
        sesionRepositoryProvider.overrideWithValue(repositorio),
        if (almacen != null) almacenLocalProvider.overrideWithValue(almacen),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('con la cuenta guardada en el celular, abre sin pedir datos', () {
    final container = crear(SesionRepositoryDemo(cuentaGuardada: cuenta));

    final sesion = container.read(sesionViewModelProvider);

    expect(sesion.cuenta, cuenta);
    // El guía se vuelve a elegir cada vez: el celular puede ser compartido.
    expect(sesion.guia, isNull);
  });

  test('sin cuenta guardada, hay que entrar', () {
    final container = crear(SesionRepositoryDemo());

    expect(container.read(sesionViewModelProvider).iniciada, isFalse);
    expect(container.read(guiasDeLaCuentaProvider), isEmpty);
  });

  test('muestra los guías de la asociación ordenados por nombre', () {
    final container = crear(SesionRepositoryDemo(cuentaGuardada: cuenta));

    final guias = container.read(guiasDeLaCuentaProvider);

    expect(guias.map((g) => g.nombre), [
      'Juan Chunga',
      'María Quispe',
      'Pedro Ancajima',
      'Rosa Yarlequé',
    ]);
    expect(guias.every((g) => g.asociacionId == cuenta.asociacionId), isTrue);
  });

  test('elegir y cambiar de guía mantiene la cuenta', () {
    final container = crear(SesionRepositoryDemo(cuentaGuardada: cuenta));
    final viewModel = container.read(sesionViewModelProvider.notifier);
    final juan = container.read(guiasDeLaCuentaProvider).first;

    viewModel.elegirGuia(juan);
    expect(container.read(sesionViewModelProvider).guia, juan);

    viewModel.cambiarGuia();
    expect(container.read(sesionViewModelProvider).guia, isNull);
    expect(container.read(sesionViewModelProvider).cuenta, cuenta);
  });

  test('salir de la cuenta la borra también del celular', () async {
    final repositorio = SesionRepositoryDemo(cuentaGuardada: cuenta);
    final container = crear(repositorio);
    final viewModel = container.read(sesionViewModelProvider.notifier);
    viewModel.elegirGuia(container.read(guiasDeLaCuentaProvider).first);

    await viewModel.cerrarSesion();

    expect(container.read(sesionViewModelProvider).iniciada, isFalse);
    expect(repositorio.cuentaGuardada(), isNull);
  });

  group('continuar como el último guía', () {
    test('la primera vez no hay a quién ofrecer', () {
      final container = crear(SesionRepositoryDemo(cuentaGuardada: cuenta));

      expect(container.read(ultimoGuiaViewModelProvider), isNull);
    });

    test('recuerda al guía que eligió su nombre', () {
      final container = crear(SesionRepositoryDemo(cuentaGuardada: cuenta));
      final juan = container.read(guiasDeLaCuentaProvider).first;

      container.read(sesionViewModelProvider.notifier).elegirGuia(juan);

      expect(container.read(ultimoGuiaViewModelProvider), juan);
    });

    test('al volver a abrir la app lo lee del celular', () {
      final almacen = AlmacenMemoria();
      final antes = crear(
        SesionRepositoryDemo(cuentaGuardada: cuenta),
        almacen: almacen,
      );
      final rosa = antes.read(guiasDeLaCuentaProvider).last;
      antes.read(sesionViewModelProvider.notifier).elegirGuia(rosa);

      final despues = crear(
        SesionRepositoryDemo(cuentaGuardada: cuenta),
        almacen: almacen,
      );

      expect(despues.read(sesionViewModelProvider).guia, isNull);
      expect(despues.read(ultimoGuiaViewModelProvider), rosa);
    });

    test('si el guía ya no está en la lista, no se ofrece', () {
      final almacen = AlmacenMemoria({
        'sesion.ultimoGuia.${cuenta.asociacionId}': 'g-que-ya-no-esta',
      });
      final container = crear(
        SesionRepositoryDemo(cuentaGuardada: cuenta),
        almacen: almacen,
      );

      expect(container.read(ultimoGuiaViewModelProvider), isNull);
    });
  });
}
