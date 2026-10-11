import 'package:explorador_bosque_seco/features/mapa/domain/coordenada.dart';
import 'package:explorador_bosque_seco/features/mapa/domain/ubicacion_repository.dart';
import 'package:explorador_bosque_seco/features/mapa/presentation/views/mapa_page.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/app_de_prueba.dart';

/// GPS apagado: el turista no activó la ubicación.
class _GpsApagado implements UbicacionRepository {
  @override
  Stream<Coordenada> posiciones() =>
      Stream.error(const UbicacionNoDisponible(ProblemaUbicacion.gpsApagado));
}

void main() {
  testWidgets('la ruta se dibuja en un mapa real, sin señal', (tester) async {
    await montarPantalla(tester, const MapaPage());

    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.text('Buscando tu ubicación (GPS)…'), findsOneWidget);
  });

  testWidgets('sin grupo vinculado, el mapa invita a escanear el QR del grupo', (
    tester,
  ) async {
    await montarPantalla(tester, const MapaPage(), grupo: null);

    expect(find.text('Escanea el QR de tu grupo'), findsOneWidget);
    expect(find.text('Escanear el QR del grupo'), findsOneWidget);
    // La ruta y los puntos no aparecen hasta escanear.
    expect(find.byType(FlutterMap), findsNothing);
  });

  testWidgets('el mapa se abre en pantalla completa', (tester) async {
    await montarPantalla(tester, const MapaPage());

    await tocar(tester, find.byTooltip('Ver en pantalla completa'));

    // En pantalla completa ya no está el botón de abrir y queda un mapa.
    expect(find.byTooltip('Ver en pantalla completa'), findsNothing);
    expect(find.byType(FlutterMap), findsOneWidget);
  });

  testWidgets('con GPS dice cuánto falta al siguiente punto', (tester) async {
    // A unos 400 m del Mirador, el siguiente punto de la demostración.
    await montarPantalla(
      tester,
      const MapaPage(),
      gps: const GpsDePrueba([Coordenada(-4.2860, -80.8545)]),
    );

    expect(find.textContaining('del siguiente punto'), findsOneWidget);
    expect(find.byTooltip('Tu ubicación'), findsOneWidget);
  });

  testWidgets('lejos del bosque explica que no está en la ruta', (
    tester,
  ) async {
    await montarPantalla(
      tester,
      const MapaPage(),
      gps: const GpsDePrueba([Coordenada(-5.1945, -80.6328)]),
    );

    expect(find.textContaining('de la ruta. Al llegar'), findsOneWidget);
  });

  testWidgets('con el GPS apagado explica cómo activarlo', (tester) async {
    await montarPantalla(tester, const MapaPage(), gps: _GpsApagado());

    expect(find.textContaining('Activa la ubicación'), findsOneWidget);
  });
}
