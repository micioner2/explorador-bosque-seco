import 'dart:typed_data';

import 'package:flutter/painting.dart' show Color;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/theme/app_colors.dart';
import '../domain/cartel_qr.dart';

PdfColor _pdf(Color color) => PdfColor.fromInt(color.toARGB32());

/// Un cartel A4 por punto, con el QR grande en negro sobre blanco (lo leen
/// todas las cámaras). Se crea en el celular, sin señal.
class GeneradorPdfCarteles implements GeneradorCarteles {
  const GeneradorPdfCarteles();

  @override
  Future<Uint8List> generar(
    List<CartelQr> carteles, {
    required String nota,
  }) async {
    final verde = _pdf(AppColors.verdeOscuro);
    final secundario = _pdf(AppColors.textoSecundario);
    final pdf = pw.Document(title: nota);
    for (final cartel in carteles) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(48),
          build: (contexto) => pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                cartel.detalle,
                style: pw.TextStyle(color: secundario, fontSize: 16),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                cartel.titulo,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  color: verde,
                  fontSize: 32,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 28),
              pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: cartel.texto,
                width: 300,
                height: 300,
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                cartel.codigo,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Text(
                nota,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(color: secundario, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }
    return pdf.save();
  }
}

final generadorCartelesProvider = Provider<GeneradorCarteles>(
  (ref) => const GeneradorPdfCarteles(),
);
