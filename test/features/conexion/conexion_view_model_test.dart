import 'dart:async';

import 'package:explorador_bosque_seco/features/conexion/data/conexion_repository_supabase.dart';
import 'package:explorador_bosque_seco/features/conexion/domain/conexion_repository.dart';
import 'package:explorador_bosque_seco/features/conexion/domain/estado_conexion.dart';
import 'package:explorador_bosque_seco/features/conexion/presentation/view_models/conexion_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Devuelve los estados indicados, uno por cada verificación.
class _RepositorioFalso implements ConexionRepository {
  _RepositorioFalso(this._estados);

  final List<EstadoConexion> _estados;
  int verificaciones = 0;

  @override
  Future<EstadoConexion> verificar() async =>
      _estados[(verificaciones++).clamp(0, _estados.length - 1)];
}

void main() {
  /// Container que mantiene vivo el ViewModel (se descarta sin oyentes).
  ProviderContainer crear([ConexionRepository? repositorio]) {
    final container = ProviderContainer(
      overrides: [
        if (repositorio != null)
          conexionRepositoryProvider.overrideWithValue(repositorio),
      ],
    );
    addTearDown(container.dispose);
    container.listen(conexionViewModelProvider, (_, _) {});
    return container;
  }

  test('sin servidor configurado no intenta conectarse', () async {
    final container = crear();

    final estado = await container.read(conexionViewModelProvider.future);

    expect(estado, isA<SinConfigurar>());
  });

  test('prueba la conexión al abrirse', () async {
    final repositorio = _RepositorioFalso([const SinConexion()]);
    final container = crear(repositorio);

    final estado = await container.read(conexionViewModelProvider.future);

    expect(estado, isA<SinConexion>());
    expect(repositorio.verificaciones, 1);
  });

  test('probar de nuevo actualiza el estado', () async {
    final repositorio = _RepositorioFalso([
      const SinConexion(),
      const Conectado(esquemaListo: true),
    ]);
    final container = crear(repositorio);
    await container.read(conexionViewModelProvider.future);

    await container.read(conexionViewModelProvider.notifier).probarDeNuevo();

    expect(container.read(conexionViewModelProvider).value, isA<Conectado>());
    expect(repositorio.verificaciones, 2);
  });

  test('mientras prueba de nuevo, el estado es "probando"', () async {
    final repositorio = _RepositorioManual();
    final container = crear(repositorio);
    repositorio.pedidos.single.complete(const SinConexion());
    await container.read(conexionViewModelProvider.future);

    final prueba = container
        .read(conexionViewModelProvider.notifier)
        .probarDeNuevo();

    expect(container.read(conexionViewModelProvider).isLoading, isTrue);
    repositorio.pedidos.last.complete(const Conectado(esquemaListo: false));
    await prueba;
    expect(container.read(conexionViewModelProvider).value, isA<Conectado>());
  });
}

/// Repositorio que responde cuando la prueba completa cada pedido.
class _RepositorioManual implements ConexionRepository {
  final pedidos = <Completer<EstadoConexion>>[];

  @override
  Future<EstadoConexion> verificar() {
    final pedido = Completer<EstadoConexion>();
    pedidos.add(pedido);
    return pedido.future;
  }
}
