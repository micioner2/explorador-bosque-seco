import 'dart:convert';
import 'dart:typed_data';

import 'package:explorador_bosque_seco/core/almacen/almacen_local.dart';
import 'package:explorador_bosque_seco/core/almacen/coleccion_local.dart';
import 'package:explorador_bosque_seco/core/l10n/l10n.dart';
import 'package:explorador_bosque_seco/core/reloj.dart';
import 'package:explorador_bosque_seco/features/reportes/data/generador_pdf_reporte.dart';
import 'package:explorador_bosque_seco/features/reportes/domain/documento_reporte.dart';
import 'package:explorador_bosque_seco/features/reportes/presentation/view_models/reporte_view_model.dart';
import 'package:explorador_bosque_seco/features/sesion/data/sesion_repository_demo.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Guarda lo que se compartió, sin abrir el menú del celular.
class _CompartirDePrueba implements CompartirArchivo {
  Uint8List? bytes;
  String? nombre;

  @override
  Future<bool> compartir(
    Uint8List bytes, {
    required String nombreArchivo,
  }) async {
    this.bytes = bytes;
    nombre = nombreArchivo;
    return true;
  }
}

/// Un generador que falla (por ejemplo, sin espacio en el celular).
class _GeneradorQueFalla implements GeneradorReporte {
  @override
  Future<Uint8List> generar(DocumentoReporte documento) =>
      Future.error(StateError('sin espacio'));
}

void main() {
  final ahora = DateTime(2026, 10, 11, 17, 45);

  test('el generador produce un PDF con contenido', () async {
    final bytes = await const GeneradorPdfReporte().generar(
      DocumentoReporte(
        marca: 'BOSQUE SECO · ASOCIACIÓN',
        titulo: 'Reporte del día',
        encabezado: const ['Coto de Caza El Angolo', 'Sábado, 11 de octubre'],
        cifras: const [CifraReporte('Visitantes', 9)],
        secciones: [
          SeccionReporte(
            titulo: 'Procedencia',
            filas: const [FilaReporte('Piura', 6), FilaReporte('Lima', 3)],
          ),
          SeccionReporte(titulo: 'Puntos más visitados', filas: const []),
        ],
        alerta: '1 grupo sigue sin salida marcada.',
        textoSinDatos: 'Sin datos',
        nota: 'Generado sin conexión desde el puesto de control',
        nombreArchivo: 'reporte.pdf',
      ),
    );

    expect(bytes, isNotEmpty);
    expect(latin1.decode(bytes.sublist(0, 5)), '%PDF-');
  });

  group('ViewModel del PDF', () {
    late AppLocalizations l10n;

    setUpAll(() async {
      // En la app lo hace MaterialApp con las traducciones de Flutter.
      await initializeDateFormatting('es');
      l10n = await AppLocalizations.delegate.load(const Locale('es'));
    });

    ProviderContainer crear({
      required CompartirArchivo compartir,
      GeneradorReporte? generador,
    }) {
      final container = ProviderContainer(
        overrides: [
          relojProvider.overrideWithValue(() => ahora),
          almacenLocalProvider.overrideWithValue(AlmacenMemoria()),
          datosDemoProvider.overrideWithValue(true),
          sesionRepositoryProvider.overrideWithValue(
            SesionRepositoryDemo(
              cuentaGuardada: SesionRepositoryDemo.cuentaDemo,
            ),
          ),
          compartirArchivoProvider.overrideWithValue(compartir),
          if (generador != null)
            generadorReporteProvider.overrideWithValue(generador),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('crea el PDF del día y abre el menú para compartirlo', () async {
      final compartir = _CompartirDePrueba();
      final app = crear(compartir: compartir);

      final listo = await app
          .read(reportePdfViewModelProvider.notifier)
          .descargar(l10n);

      expect(listo, isTrue);
      expect(compartir.nombre, 'reporte-2026-10-11.pdf');
      expect(latin1.decode(compartir.bytes!.sublist(0, 5)), '%PDF-');
      expect(app.read(reportePdfViewModelProvider), EstadoPdf.listo);
    });

    test('si falla, avisa con el estado de error y no comparte', () async {
      final compartir = _CompartirDePrueba();
      final app = crear(compartir: compartir, generador: _GeneradorQueFalla());

      final listo = await app
          .read(reportePdfViewModelProvider.notifier)
          .descargar(l10n);

      expect(listo, isFalse);
      expect(compartir.bytes, isNull);
      expect(app.read(reportePdfViewModelProvider), EstadoPdf.error);
    });
  });
}
