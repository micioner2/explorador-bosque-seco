import 'dart:typed_data';

import 'package:flutter/painting.dart' show Color;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/documento_reporte.dart';

PdfColor _pdf(Color color) => PdfColor.fromInt(color.toARGB32());

/// Dibuja el reporte del día en un PDF A4 con la paleta de la app. Usa la
/// tipografía incluida en el PDF: no descarga nada, funciona sin señal.
/// No calcula nada: todo viene en el [DocumentoReporte].
class GeneradorPdfReporte implements GeneradorReporte {
  const GeneradorPdfReporte();

  static final _verde = _pdf(AppColors.verdeOscuro);
  static final _verdeSuave = _pdf(AppColors.verdeSuave);
  static final _barra = _pdf(AppColors.verdeInstitucional);
  static final _texto = _pdf(AppColors.negroGrisaceo);
  static final _secundario = _pdf(AppColors.textoSecundario);
  static final _borde = _pdf(AppColors.borde);
  static final _alerta = _pdf(AppColors.alerta);
  static final _alertaSuave = _pdf(AppColors.alertaSuave);
  static final _marron = _pdf(AppColors.marronTierra);

  @override
  Future<Uint8List> generar(DocumentoReporte documento) async {
    final pdf = pw.Document(
      title: documento.titulo,
      author: documento.marca,
      creator: documento.marca,
    );
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        footer: (contexto) => _pie(documento, contexto),
        build: (contexto) => [
          _cabecera(documento),
          pw.SizedBox(height: 16),
          _cifras(documento.cifras),
          if (documento.alerta case final alerta?) ...[
            pw.SizedBox(height: 12),
            _aviso(alerta),
          ],
          for (final seccion in documento.secciones) ...[
            pw.SizedBox(height: 18),
            _seccion(seccion, documento.textoSinDatos),
          ],
        ],
      ),
    );
    return pdf.save();
  }

  pw.Widget _cabecera(DocumentoReporte documento) => pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      color: _verde,
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          documento.marca,
          style: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          documento.titulo,
          style: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        for (final linea in documento.encabezado)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 3),
            child: pw.Text(
              linea,
              style: const pw.TextStyle(color: PdfColors.white, fontSize: 11),
            ),
          ),
      ],
    ),
  );

  pw.Widget _cifras(List<CifraReporte> cifras) => pw.Row(
    children: [
      for (final (indice, cifra) in cifras.indexed) ...[
        if (indice > 0) pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: _verdeSuave,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${cifra.valor}',
                  style: pw.TextStyle(
                    color: _verde,
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  cifra.etiqueta,
                  style: pw.TextStyle(color: _secundario, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ],
    ],
  );

  pw.Widget _aviso(String texto) => pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: _alertaSuave,
      border: pw.Border.all(color: _alerta),
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Text(texto, style: pw.TextStyle(color: _alerta, fontSize: 11)),
  );

  pw.Widget _seccion(SeccionReporte seccion, String sinDatos) {
    final total = seccion.total;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          seccion.titulo,
          style: pw.TextStyle(
            color: _verde,
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Divider(color: _borde),
        if (seccion.filas.isEmpty)
          pw.Text(sinDatos, style: pw.TextStyle(color: _secundario))
        else
          for (final fila in seccion.filas)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 3),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.SizedBox(
                    width: 170,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          fila.etiqueta,
                          style: pw.TextStyle(color: _texto, fontSize: 11),
                        ),
                        if (fila.detalle case final detalle?)
                          pw.Text(
                            detalle,
                            style: pw.TextStyle(
                              color: _secundario,
                              fontSize: 9,
                            ),
                          ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.LayoutBuilder(
                      // Align suelta el ancho que impone Expanded, para
                      // que la barra mida su proporción del total.
                      builder: (contexto, limites) => pw.Align(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Container(
                          height: 10,
                          width: total == 0
                              ? 0
                              : (limites?.maxWidth ?? 200) *
                                    fila.cantidad /
                                    total,
                          decoration: pw.BoxDecoration(
                            color: _barra,
                            borderRadius: pw.BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(
                    width: 40,
                    child: pw.Text(
                      '${fila.cantidad}',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        color: _texto,
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }

  pw.Widget _pie(DocumentoReporte documento, pw.Context contexto) =>
      pw.Container(
        padding: const pw.EdgeInsets.only(top: 8),
        decoration: pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: _borde)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              documento.nota,
              style: pw.TextStyle(color: _marron, fontSize: 9),
            ),
            pw.Text(
              '${contexto.pageNumber}/${contexto.pagesCount}',
              style: pw.TextStyle(color: _secundario, fontSize: 9),
            ),
          ],
        ),
      );
}

/// Comparte el PDF con el menú del celular (WhatsApp, Drive, Descargas).
class CompartirArchivoSistema implements CompartirArchivo {
  const CompartirArchivoSistema();

  @override
  Future<bool> compartir(Uint8List bytes, {required String nombreArchivo}) =>
      Printing.sharePdf(bytes: bytes, filename: nombreArchivo);
}

final generadorReporteProvider = Provider<GeneradorReporte>(
  (ref) => const GeneradorPdfReporte(),
);

final compartirArchivoProvider = Provider<CompartirArchivo>(
  (ref) => const CompartirArchivoSistema(),
);
