import 'dart:convert';
import 'dart:typed_data';

import 'package:explorador_bosque_seco/core/almacen/almacen_local.dart';
import 'package:explorador_bosque_seco/core/almacen/coleccion_local.dart';
import 'package:explorador_bosque_seco/core/l10n/l10n.dart';
import 'package:explorador_bosque_seco/features/escaneo/data/generador_pdf_carteles.dart';
import 'package:explorador_bosque_seco/features/escaneo/domain/cartel_qr.dart';
import 'package:explorador_bosque_seco/features/escaneo/domain/resultado_escaneo.dart';
import 'package:explorador_bosque_seco/features/escaneo/presentation/view_models/escaneo_view_model.dart';
import 'package:explorador_bosque_seco/features/escaneo/presentation/view_models/qr_prueba_view_model.dart';
import 'package:explorador_bosque_seco/features/escaneo/presentation/views/qr_prueba_page.dart';
import 'package:explorador_bosque_seco/features/reportes/data/generador_pdf_reporte.dart';
import 'package:explorador_bosque_seco/features/reportes/domain/documento_reporte.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/app_de_prueba.dart';

class _CompartirDePrueba implements CompartirArchivo {
  Uint8List? bytes;

  @override
  Future<bool> compartir(
    Uint8List bytes, {
    required String nombreArchivo,
  }) async {
    this.bytes = bytes;
    return true;
  }
}

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  test('escanear los carteles de prueba vincula el grupo y da sellos', () {
    final app = ProviderContainer(
      overrides: [
        almacenLocalProvider.overrideWithValue(AlmacenMemoria()),
        datosDemoProvider.overrideWithValue(true),
      ],
    );
    addTearDown(app.dispose);
    app.listen(escaneoViewModelProvider, (_, _) {});
    final datos = app.read(datosQrPruebaProvider);
    final carteles = cartelesDePrueba(
      l10n,
      puntos: datos.puntos,
      conGrupo: datos.conGrupo,
    );
    final escaneo = app.read(escaneoViewModelProvider.notifier);

    expect(escaneo.procesar(carteles.first.texto), isA<GrupoVinculado>());
    // El grupo de prueba ya tiene 3 sellos: el Mirador es nuevo.
    final mirador = carteles.firstWhere((c) => c.codigo == 'mirador');
    expect(escaneo.procesar(mirador.texto), isA<SelloGanado>());
  });

  test('el PDF de los carteles se crea sin señal', () async {
    final bytes = await const GeneradorPdfCarteles().generar(const [
      CartelQr(
        titulo: 'Mirador',
        detalle: 'Punto 4 de 5',
        texto: 'bosqueseco:punto:mirador',
        codigo: 'mirador',
      ),
    ], nota: 'Prueba');

    expect(latin1.decode(bytes.sublist(0, 5)), '%PDF-');
  });

  testWidgets('la pantalla muestra los QR y descarga el PDF', (tester) async {
    final compartir = _CompartirDePrueba();
    await montarPantalla(
      tester,
      const QrPruebaPage(),
      overrides: [compartirArchivoProvider.overrideWithValue(compartir)],
    );

    expect(find.text('Grupo de prueba'), findsOneWidget);
    expect(find.text('Código: entrada'), findsOneWidget);

    await tester.runAsync(
      () => tester.tap(find.text('Descargar PDF de los QR')),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 2)),
    );
    await tester.pumpAndSettle();

    expect(compartir.bytes, isNotNull);
  });
}
