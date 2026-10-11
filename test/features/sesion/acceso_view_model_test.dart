import 'dart:async';

import 'package:explorador_bosque_seco/features/sesion/data/sesion_repository_demo.dart';
import 'package:explorador_bosque_seco/features/sesion/domain/cuenta_asociacion.dart';
import 'package:explorador_bosque_seco/features/sesion/domain/resultado_acceso.dart';
import 'package:explorador_bosque_seco/features/sesion/domain/sesion_repository.dart';
import 'package:explorador_bosque_seco/features/sesion/presentation/view_models/acceso_view_model.dart';
import 'package:explorador_bosque_seco/features/sesion/presentation/view_models/sesion_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repositorio que responde cuando la prueba completa cada pedido.
class _RepositorioManual implements SesionRepository {
  final pedidos = <Completer<ResultadoAcceso>>[];

  @override
  CuentaAsociacion? cuentaGuardada() => null;

  @override
  Future<ResultadoAcceso> iniciarSesion({
    required String correo,
    required String clave,
  }) {
    final pedido = Completer<ResultadoAcceso>();
    pedidos.add(pedido);
    return pedido.future;
  }

  @override
  Future<void> cerrarSesion() async {}
}

void main() {
  /// Container que mantiene vivo el ViewModel (se descarta sin oyentes).
  ProviderContainer crear(SesionRepository repositorio) {
    final container = ProviderContainer(
      overrides: [sesionRepositoryProvider.overrideWithValue(repositorio)],
    );
    addTearDown(container.dispose);
    container.listen(accesoViewModelProvider, (_, _) {});
    return container;
  }

  AccesoViewModel viewModel(ProviderContainer container) =>
      container.read(accesoViewModelProvider.notifier);

  test('con la cuenta correcta abre la sesión de la asociación', () async {
    final container = crear(SesionRepositoryDemo());

    final entro = await viewModel(container).entrar(
      correo: ' Demo@BosqueSeco.pe ',
      clave: SesionRepositoryDemo.claveDemo,
    );

    expect(entro, isTrue);
    expect(
      container.read(sesionViewModelProvider).cuenta,
      SesionRepositoryDemo.cuentaDemo,
    );
    expect(container.read(accesoViewModelProvider).rechazo, isNull);
  });

  test('con la contraseña equivocada dice por qué y no abre nada', () async {
    final container = crear(SesionRepositoryDemo());

    final entro = await viewModel(
      container,
    ).entrar(correo: SesionRepositoryDemo.correoDemo, clave: 'otra');

    expect(entro, isFalse);
    expect(
      container.read(accesoViewModelProvider).rechazo?.motivo,
      MotivoRechazo.credencialesIncorrectas,
    );
    expect(container.read(sesionViewModelProvider).iniciada, isFalse);
  });

  test('mientras verifica, muestra que está entrando y no repite '
      'el pedido', () async {
    final repositorio = _RepositorioManual();
    final container = crear(repositorio);

    final intento = viewModel(container).entrar(correo: 'a@b.pe', clave: 'x');
    final repetido = await viewModel(
      container,
    ).entrar(correo: 'a@b.pe', clave: 'x');

    expect(container.read(accesoViewModelProvider).entrando, isTrue);
    expect(repetido, isFalse);
    expect(repositorio.pedidos, hasLength(1));

    repositorio.pedidos.single.complete(
      const AccesoDenegado(MotivoRechazo.sinConexion),
    );
    expect(await intento, isFalse);
    final estado = container.read(accesoViewModelProvider);
    expect(estado.entrando, isFalse);
    expect(estado.rechazo?.motivo, MotivoRechazo.sinConexion);
  });

  test('solo sin servidor ofrece la cuenta de prueba', () {
    expect(
      crear(SesionRepositoryDemo()).read(accesoViewModelProvider).cuentaDemo,
      isNotNull,
    );
    expect(
      crear(_RepositorioManual()).read(accesoViewModelProvider).cuentaDemo,
      isNull,
    );
  });
}
