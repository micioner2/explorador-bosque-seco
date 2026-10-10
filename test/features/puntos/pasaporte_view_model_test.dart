import 'package:explorador_bosque_seco/core/reloj.dart';
import 'package:explorador_bosque_seco/features/puntos/data/puntos_repository_demo.dart';
import 'package:explorador_bosque_seco/features/puntos/domain/pasaporte.dart';
import 'package:explorador_bosque_seco/features/puntos/domain/producto.dart';
import 'package:explorador_bosque_seco/features/puntos/domain/puntos_repository.dart';
import 'package:explorador_bosque_seco/features/puntos/presentation/view_models/pasaporte_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _PasaporteVacio implements PuntosRepository {
  @override
  Pasaporte pasaporte() => Pasaporte();

  @override
  List<Producto> productos() => const [];
}

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        relojProvider.overrideWithValue(() => DateTime(2026, 10, 10, 10)),
        puntosRepositoryProvider.overrideWithValue(_PasaporteVacio()),
      ],
    );
    addTearDown(container.dispose);
  });

  PasaporteViewModel viewModel() =>
      container.read(pasaporteViewModelProvider.notifier);

  Pasaporte estado() => container.read(pasaporteViewModelProvider);

  test('escanear un punto nuevo deja un punto pendiente', () {
    final resultado = viewModel().registrarEscaneo(
      visitaId: 'v1',
      puntoId: 'pozas',
    );

    expect(resultado, isA<PuntoGanado>());
    expect(estado().puntosPendientes, 1);
  });

  test('escanear dos veces el mismo punto no cambia el pasaporte', () {
    viewModel().registrarEscaneo(visitaId: 'v1', puntoId: 'pozas');

    final resultado = viewModel().registrarEscaneo(
      visitaId: 'v1',
      puntoId: 'pozas',
    );

    expect(resultado, isA<PuntoYaRegistrado>());
    expect(estado().escaneos, hasLength(1));
  });

  test('al confirmar y canjear se descuentan los puntos', () {
    viewModel().registrarEscaneo(visitaId: 'v1', puntoId: 'pozas');
    viewModel().registrarEscaneo(visitaId: 'v1', puntoId: 'caida');
    viewModel().confirmar({for (final e in estado().escaneos) e.id});

    viewModel().canjear(
      Producto(
        id: 'miel',
        nombre: 'Miel',
        puntosRequeridos: 2,
        porcentajeDescuento: 10,
      ),
    );

    expect(estado().puntosDisponibles, 0);
  });
}
