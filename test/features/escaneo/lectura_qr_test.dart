import 'package:explorador_bosque_seco/features/escaneo/domain/lectura_qr.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el QR del grupo lleva el id de la visita', () {
    final lectura = LecturaQr.desde('bosqueseco:visita:3f2a-91');

    expect(lectura, isA<QrDeGrupo>());
    expect((lectura as QrDeGrupo).visitaId, '3f2a-91');
  });

  test('el QR de un punto lleva el id del punto', () {
    final lectura = LecturaQr.desde('bosqueseco:punto:mirador');

    expect(lectura, isA<QrDePunto>());
    expect((lectura as QrDePunto).puntoId, 'mirador');
  });

  test('el código del punto escrito a mano también vale', () {
    final lectura = LecturaQr.desde('  Mirador ');

    expect(lectura, isA<QrDePunto>());
    expect((lectura as QrDePunto).puntoId, 'mirador');
  });

  test('el texto impreso en el cartel se puede volver a leer', () {
    final texto = LecturaQr.textoDePunto('pozas');

    expect((LecturaQr.desde(texto) as QrDePunto).puntoId, 'pozas');
  });

  test('un QR que no es de la app no se confunde con un punto', () {
    expect(LecturaQr.desde('https://ejemplo.com'), isA<QrDesconocido>());
    expect(LecturaQr.desde('bosqueseco:visita:'), isA<QrDesconocido>());
    expect(LecturaQr.desde('otraapp:punto:mirador'), isA<QrDesconocido>());
    expect(LecturaQr.desde(''), isA<QrDesconocido>());
  });
}
