import 'package:explorador_bosque_seco/core/almacen/almacen_local.dart';
import 'package:explorador_bosque_seco/core/reloj.dart';
import 'package:explorador_bosque_seco/features/escaneo/domain/resultado_escaneo.dart';
import 'package:explorador_bosque_seco/features/escaneo/presentation/view_models/escaneo_view_model.dart';
import 'package:explorador_bosque_seco/features/puntos/data/puntos_repository_demo.dart';
import 'package:explorador_bosque_seco/features/puntos/domain/pasaporte.dart';
import 'package:explorador_bosque_seco/features/puntos/domain/producto.dart';
import 'package:explorador_bosque_seco/features/puntos/domain/puntos_repository.dart';
import 'package:explorador_bosque_seco/features/puntos/presentation/view_models/pasaporte_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pasaporte vacío: el turista aún no escaneó nada.
class _PuntosVacios implements PuntosRepository {
  @override
  Pasaporte pasaporte() => Pasaporte();

  @override
  List<Producto> productos() => const [];
}

void main() {
  ProviderContainer crear({AlmacenLocal? almacen}) {
    final container = ProviderContainer(
      overrides: [
        relojProvider.overrideWithValue(() => DateTime(2026, 10, 10, 9)),
        puntosRepositoryProvider.overrideWithValue(_PuntosVacios()),
        if (almacen != null) almacenLocalProvider.overrideWithValue(almacen),
      ],
    );
    addTearDown(container.dispose);
    // Mantiene vivo el ViewModel de la pantalla durante la prueba.
    container.listen(escaneoViewModelProvider, (_, _) {});
    return container;
  }

  ResultadoEscaneo escanear(ProviderContainer container, String texto) =>
      container.read(escaneoViewModelProvider.notifier).procesar(texto);

  test('sin grupo, el QR de un punto pide vincular primero', () {
    final container = crear();

    final resultado = escanear(container, 'bosqueseco:punto:mirador');

    expect(resultado, isA<FaltaGrupo>());
    expect((resultado as FaltaGrupo).punto.nombre, 'Mirador');
    expect(container.read(pasaporteViewModelProvider).sellos, isEmpty);
  });

  test('el QR del grupo vincula el celular a la visita', () {
    final container = crear();

    final resultado = escanear(container, 'bosqueseco:visita:v7');

    expect(resultado, isA<GrupoVinculado>());
    expect((resultado as GrupoVinculado).yaEstaba, isFalse);
    expect(container.read(vinculoViewModelProvider), 'v7');
  });

  test('volver a escanear el QR del mismo grupo no cambia nada', () {
    final container = crear();
    escanear(container, 'bosqueseco:visita:v7');

    final resultado = escanear(container, 'bosqueseco:visita:v7');

    expect((resultado as GrupoVinculado).yaEstaba, isTrue);
  });

  test('con grupo, el punto da su sello pendiente a esa visita', () {
    final container = crear();
    escanear(container, 'bosqueseco:visita:v7');

    final resultado = escanear(container, 'bosqueseco:punto:pozas');

    expect(resultado, isA<SelloGanado>());
    final pasaporte = container.read(pasaporteViewModelProvider);
    expect(pasaporte.sellos.single.visitaId, 'v7');
    expect(pasaporte.sellos.single.puntoId, 'pozas');
    expect(pasaporte.puntosPendientes, 1);
  });

  test('escanear dos veces el mismo punto no suma de nuevo', () {
    final container = crear();
    escanear(container, 'bosqueseco:visita:v7');
    escanear(container, 'bosqueseco:punto:pozas');

    final resultado = escanear(container, 'pozas');

    expect(resultado, isA<SelloRepetido>());
    expect(container.read(pasaporteViewModelProvider).sellos, hasLength(1));
  });

  test('un punto que no es de la ruta no da sello', () {
    final container = crear();
    escanear(container, 'bosqueseco:visita:v7');

    expect(escanear(container, 'bosqueseco:punto:cascada'), isA<PuntoAjeno>());
    expect(escanear(container, 'https://ejemplo.com'), isA<QrAjeno>());
    expect(container.read(pasaporteViewModelProvider).sellos, isEmpty);
  });

  test('el vínculo con el grupo se guarda en el celular', () {
    final almacen = AlmacenMemoria();
    escanear(crear(almacen: almacen), 'bosqueseco:visita:v7');

    final otraVez = crear(almacen: almacen);

    expect(otraVez.read(vinculoViewModelProvider), 'v7');
  });

  test('el resultado se muestra hasta el siguiente escaneo', () {
    final container = crear();

    escanear(container, 'bosqueseco:visita:v7');

    expect(container.read(escaneoViewModelProvider), isA<GrupoVinculado>());
  });
}
