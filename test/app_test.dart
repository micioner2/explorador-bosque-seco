import 'package:explorador_bosque_seco/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> abrirApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: BosqueSecoApp()));
    await tester.pumpAndSettle();
  }

  testWidgets('abre en Explorar con el espacio y sus servicios', (
    tester,
  ) async {
    await abrirApp(tester);

    expect(find.text('Coto de Caza El Angolo'), findsOneWidget);
    expect(find.text('Atractivos'), findsOneWidget);
    expect(find.text('Explorar'), findsOneWidget);
  });

  testWidgets('navega al pasaporte y muestra los puntos', (tester) async {
    await abrirApp(tester);

    await tester.tap(find.text('Pasaporte'));
    await tester.pumpAndSettle();

    expect(find.text('Mi pasaporte'), findsOneWidget);
    expect(find.text('2 confirmados · 1 pendientes'), findsOneWidget);
  });

  testWidgets('cambia al modo asociación', (tester) async {
    await abrirApp(tester);

    await tester.tap(find.byTooltip('Modo asociación'));
    await tester.pumpAndSettle();

    expect(find.text('Hoy en el puesto de control'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
