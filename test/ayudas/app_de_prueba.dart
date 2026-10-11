import 'package:explorador_bosque_seco/app.dart';
import 'package:explorador_bosque_seco/core/l10n/l10n.dart';
import 'package:explorador_bosque_seco/core/reloj.dart';
import 'package:explorador_bosque_seco/core/theme/app_theme.dart';
import 'package:explorador_bosque_seco/features/preferencias/data/preferencias_repository_memoria.dart';
import 'package:explorador_bosque_seco/features/preferencias/domain/preferencias.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mediodía de la demostración: de las visitas de ejemplo, solo el grupo
/// Ramírez (salida prevista 11:00) ya pasó su hora.
final mediodia = DateTime(2026, 10, 10, 12);

/// Abre la app completa con idioma, apariencia y hora fijos, para que las
/// pruebas no dependan del celular ni del reloj de quien las corre.
Future<void> abrirApp(
  WidgetTester tester, {
  Idioma idioma = Idioma.es,
  ModoTema modoTema = ModoTema.claro,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        relojProvider.overrideWithValue(() => mediodia),
        preferenciasRepositoryProvider.overrideWithValue(
          PreferenciasRepositoryMemoria(
            Preferencias(idioma: idioma, modoTema: modoTema),
          ),
        ),
      ],
      child: const BosqueSecoApp(),
    ),
  );
  await tester.pumpAndSettle();
}

/// Monta una sola pantalla, sin navegación, con el tema y el idioma dados.
Future<void> montarPantalla(
  WidgetTester tester,
  Widget pantalla, {
  Idioma idioma = Idioma.es,
  bool oscuro = false,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [relojProvider.overrideWithValue(() => mediodia)],
      child: MaterialApp(
        theme: oscuro ? AppTheme.oscuro : AppTheme.claro,
        locale: Locale(idioma.codigo),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: pantalla,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Toca un elemento, desplazando la lista antes si quedó fuera de la vista.
Future<void> tocar(WidgetTester tester, Finder elemento) async {
  await tester.ensureVisible(elemento);
  await tester.pumpAndSettle();
  await tester.tap(elemento);
  await tester.pumpAndSettle();
}
