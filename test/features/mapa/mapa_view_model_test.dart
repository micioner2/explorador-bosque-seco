import 'package:explorador_bosque_seco/core/reloj.dart';
import 'package:explorador_bosque_seco/features/mapa/data/ruta_repository_demo.dart';
import 'package:explorador_bosque_seco/features/mapa/domain/ruta.dart';
import 'package:explorador_bosque_seco/features/mapa/domain/ruta_repository.dart';
import 'package:explorador_bosque_seco/features/mapa/presentation/view_models/mapa_view_model.dart';
import 'package:explorador_bosque_seco/features/puntos/data/puntos_repository_local.dart';
import 'package:explorador_bosque_seco/features/puntos/domain/pasaporte.dart';
import 'package:explorador_bosque_seco/features/puntos/domain/producto.dart';
import 'package:explorador_bosque_seco/features/puntos/domain/puntos_repository.dart';
import 'package:explorador_bosque_seco/features/puntos/presentation/view_models/pasaporte_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _RutaCorta implements RutaRepository {
  @override
  Ruta rutaActual() => Ruta(
    id: 'r1',
    nombre: 'Ruta corta',
    puntos: [
      PuntoRuta(id: 'entrada', nombre: 'Entrada'),
      PuntoRuta(id: 'pozas', nombre: 'Pozas', metrosDesdeAnterior: 1500),
    ],
  );
}

class _PasaporteVacio implements PuntosRepository {
  @override
  Pasaporte pasaporte() => Pasaporte();

  @override
  Future<void> guardar(Pasaporte pasaporte) async {}

  @override
  List<Producto> productos() => const [];
}

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        relojProvider.overrideWithValue(() => DateTime(2026, 10, 10, 10)),
        rutaRepositoryProvider.overrideWithValue(_RutaCorta()),
        puntosRepositoryProvider.overrideWithValue(_PasaporteVacio()),
      ],
    );
    addTearDown(container.dispose);
  });

  PasaporteViewModel pasaporte() =>
      container.read(pasaporteViewModelProvider.notifier);

  test('al escanear un punto, el mapa avanza al siguiente', () {
    expect(
      container.read(mapaViewModelProvider).siguiente?.punto.id,
      'entrada',
    );

    pasaporte().registrarEscaneo(visitaId: 'v1', puntoId: 'entrada');

    final progreso = container.read(mapaViewModelProvider);
    expect(progreso.visitados, 1);
    expect(progreso.siguiente?.punto.id, 'pozas');
  });

  test('escanear dos veces el mismo punto no avanza de nuevo', () {
    pasaporte().registrarEscaneo(visitaId: 'v1', puntoId: 'entrada');
    pasaporte().registrarEscaneo(visitaId: 'v1', puntoId: 'entrada');

    expect(container.read(mapaViewModelProvider).visitados, 1);
  });

  test('al escanear el último punto la ruta queda completa', () {
    pasaporte().registrarEscaneo(visitaId: 'v1', puntoId: 'entrada');
    pasaporte().registrarEscaneo(visitaId: 'v1', puntoId: 'pozas');

    final progreso = container.read(mapaViewModelProvider);
    expect(progreso.completada, isTrue);
    expect(progreso.siguiente, isNull);
  });
}
