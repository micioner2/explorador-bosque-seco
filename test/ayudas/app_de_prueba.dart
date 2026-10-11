import 'package:explorador_bosque_seco/app.dart';
import 'package:explorador_bosque_seco/core/l10n/l10n.dart';
import 'package:explorador_bosque_seco/core/reloj.dart';
import 'package:explorador_bosque_seco/core/theme/app_theme.dart';
import 'package:explorador_bosque_seco/features/escaneo/presentation/views/visor_camara.dart';
import 'package:explorador_bosque_seco/features/preferencias/data/preferencias_repository_memoria.dart';
import 'package:explorador_bosque_seco/features/preferencias/domain/preferencias.dart';
import 'package:explorador_bosque_seco/features/sesion/data/sesion_repository_demo.dart';
import 'package:explorador_bosque_seco/features/sesion/domain/guia.dart';
import 'package:explorador_bosque_seco/features/sesion/domain/sesion.dart';
import 'package:explorador_bosque_seco/features/sesion/presentation/view_models/sesion_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

/// Mediodía de la demostración: de las visitas de ejemplo, solo el grupo
/// Ramírez (salida prevista 11:00) ya pasó su hora.
final mediodia = DateTime(2026, 10, 10, 12);

/// Guía con el que las pruebas usan el puesto de control.
final guiaDePrueba = Guia(
  id: 'g1',
  asociacionId: SesionRepositoryDemo.cuentaDemo.asociacionId,
  nombre: 'María Quispe',
);

/// Sesión del puesto de control lista para registrar: cuenta de
/// demostración y [guiaDePrueba].
final sesionDePrueba = Sesion(
  cuenta: SesionRepositoryDemo.cuentaDemo,
  guia: guiaDePrueba,
);

/// ViewModel de sesión que empieza con la sesión dada, sin pasar por el
/// acceso.
class SesionViewModelFijo extends SesionViewModel {
  SesionViewModelFijo(this._inicial);

  final Sesion _inicial;

  @override
  Sesion build() => _inicial;
}

/// En las pruebas no hay cámara: se escanea escribiendo el código, como
/// haría el turista si la cámara no lee el cartel.
final sinCamara = visorCamaraProvider.overrideWithValue(
  (context, alLeer) => const SizedBox.expand(),
);

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
        sinCamara,
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

/// Desde el modo turista, entra al puesto de control como lo haría una
/// persona: abre el modo asociación, entra con la cuenta de prueba y toca
/// el nombre de [guia].
Future<void> entrarAlPuesto(
  WidgetTester tester, {
  String guia = 'María Quispe',
}) async {
  await tocar(tester, find.byTooltip('Modo asociación'));
  await tocar(tester, find.text('Usar cuenta de prueba'));
  await tocar(tester, find.text('Entrar'));
  await tocar(tester, find.text(guia));
  // Espera a que se vaya el saludo, que puede tapar los botones de abajo.
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

/// Monta una sola pantalla, sin navegación, con el tema y el idioma dados.
/// Las pantallas del puesto de control ven [sesion] (por defecto,
/// [sesionDePrueba]). [overrides] permite sustituir repositorios por dobles
/// de prueba.
Future<void> montarPantalla(
  WidgetTester tester,
  Widget pantalla, {
  Idioma idioma = Idioma.es,
  bool oscuro = false,
  Sesion? sesion,
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        relojProvider.overrideWithValue(() => mediodia),
        sinCamara,
        sesionViewModelProvider.overrideWith(
          () => SesionViewModelFijo(sesion ?? sesionDePrueba),
        ),
        ...overrides,
      ],
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

/// Toca un elemento. Como una persona, solo desplaza la lista si no se puede
/// tocar donde está (fuera de la pantalla o tapado por la barra o el botón
/// flotante).
Future<void> tocar(WidgetTester tester, Finder elemento) async {
  if (!tester.any(elemento.hitTestable())) {
    await tester.ensureVisible(elemento);
    await tester.pumpAndSettle();
  }
  await tester.tap(elemento);
  await tester.pumpAndSettle();
}

/// Escanea [codigo] escribiéndolo en "¿No lee? Escribe el código".
Future<void> escanearCodigo(WidgetTester tester, String codigo) async {
  await tocar(tester, find.text('¿No lee? Escribe el código'));
  await tester.enterText(find.byType(TextField), codigo);
  await tocar(tester, find.text('Listo'));
}
