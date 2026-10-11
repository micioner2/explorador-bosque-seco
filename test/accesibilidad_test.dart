import 'package:explorador_bosque_seco/features/escaneo/presentation/views/escanear_page.dart';
import 'package:explorador_bosque_seco/features/escaneo/presentation/views/qr_prueba_page.dart';
import 'package:explorador_bosque_seco/features/explorar/presentation/views/explorar_page.dart';
import 'package:explorador_bosque_seco/features/mapa/presentation/views/mapa_page.dart';
import 'package:explorador_bosque_seco/features/preferencias/domain/preferencias.dart';
import 'package:explorador_bosque_seco/features/preferencias/presentation/views/ajustes_page.dart';
import 'package:explorador_bosque_seco/features/puntos/presentation/views/pasaporte_page.dart';
import 'package:explorador_bosque_seco/features/reportes/presentation/views/reporte_page.dart';
import 'package:explorador_bosque_seco/features/reservas/presentation/views/formulario_reserva_page.dart';
import 'package:explorador_bosque_seco/features/reservas/presentation/views/reservas_page.dart';
import 'package:explorador_bosque_seco/features/sesion/presentation/views/acceso_page.dart';
import 'package:explorador_bosque_seco/features/sesion/presentation/views/elegir_guia_page.dart';
import 'package:explorador_bosque_seco/features/visitas/presentation/views/hoy_page.dart';
import 'package:explorador_bosque_seco/features/visitas/presentation/views/registrar_visitante_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudas/app_de_prueba.dart';

/// Requisito N4 (uso al aire libre): cada pantalla debe leerse con sol,
/// tocarse con el pulgar y funcionar con lector de pantalla y letra grande,
/// en los dos temas y en los dos idiomas.
const _pantallas = <String, Widget>{
  'Explorar': ExplorarPage(),
  'Mapa': MapaPage(),
  'Pasaporte': PasaportePage(),
  'Escanear': EscanearPage(),
  'QR de prueba': QrPruebaPage(),
  'Acceso': AccesoPage(),
  'Elegir guía': ElegirGuiaPage(),
  'Hoy': HoyPage(),
  'Reservas': ReservasPage(),
  'Nueva reserva': FormularioReservaPage(),
  // Reserva de demostración de un día anterior (no llegó).
  'Reprogramar reserva': FormularioReservaPage(reservaId: 'r1'),
  'Registrar visitante': RegistrarVisitantePage(),
  'Reporte': ReportePage(),
  'Ajustes': AjustesPage(),
};

void main() {
  /// Pantalla alta para que toda la lista quede dibujada y se revise entera.
  void usarPantalla(WidgetTester tester, Size tamano) {
    tester.view.physicalSize = tamano;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> esperarAccesible(WidgetTester tester) async {
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  }

  for (final oscuro in [false, true]) {
    final tema = oscuro ? 'oscuro' : 'claro';

    group('modo $tema', () {
      for (final MapEntry(key: nombre, value: pantalla) in _pantallas.entries) {
        testWidgets('$nombre tiene contraste, botones de 48 px y etiquetas', (
          tester,
        ) async {
          final semantica = tester.ensureSemantics();
          usarPantalla(tester, const Size(400, 2400));

          await montarPantalla(tester, pantalla, oscuro: oscuro);

          await esperarAccesible(tester);
          semantica.dispose();
        });
      }

      testWidgets('la navegación y el botón de escanear son accesibles', (
        tester,
      ) async {
        final semantica = tester.ensureSemantics();
        usarPantalla(tester, const Size(400, 2400));

        await abrirApp(
          tester,
          modoTema: oscuro ? ModoTema.oscuro : ModoTema.claro,
        );
        await esperarAccesible(tester);

        await tocar(tester, find.byTooltip('Modo asociación'));
        await esperarAccesible(tester);

        await tocar(tester, find.text('Usar cuenta de prueba'));
        await tocar(tester, find.text('María Quispe'));
        await esperarAccesible(tester);
        semantica.dispose();
      });

      testWidgets('la hoja "Tu sesión" es accesible', (tester) async {
        final semantica = tester.ensureSemantics();
        usarPantalla(tester, const Size(400, 2400));

        await montarPantalla(tester, const HoyPage(), oscuro: oscuro);
        await tocar(tester, find.byTooltip('Tu sesión'));

        expect(find.text('Cambiar de guía'), findsOneWidget);
        await esperarAccesible(tester);
        semantica.dispose();
      });

      testWidgets('el QR del grupo es accesible', (tester) async {
        final semantica = tester.ensureSemantics();
        usarPantalla(tester, const Size(400, 2400));

        await montarPantalla(tester, const HoyPage(), oscuro: oscuro);
        await tocar(tester, find.text('Ver QR').first);

        expect(find.bySemanticsLabel(RegExp('Código QR del grupo')), findsOne);
        await esperarAccesible(tester);
        semantica.dispose();
      });
    });
  }

  for (final idioma in Idioma.values) {
    group('celular pequeño con letra grande (${idioma.codigo})', () {
      for (final MapEntry(key: nombre, value: pantalla) in _pantallas.entries) {
        // Si algún texto se sale de su caja, Flutter lanza un error de
        // desborde y la prueba falla.
        testWidgets('$nombre no se desborda', (tester) async {
          usarPantalla(tester, const Size(320, 3600));
          tester.platformDispatcher.textScaleFactorTestValue = 1.6;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

          await montarPantalla(tester, pantalla, idioma: idioma);

          expect(tester.takeException(), isNull);
        });
      }
    });
  }
}
