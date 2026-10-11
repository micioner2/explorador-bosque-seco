import 'package:explorador_bosque_seco/features/explorar/domain/espacio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Servicio conNumero(String whatsapp) => Servicio(
    id: 's1',
    tipo: TipoServicio.guiado,
    nombre: 'Guiado comunitario',
    whatsapp: whatsapp,
  );

  group('número de WhatsApp', () {
    test('un celular peruano escrito con espacios recibe el prefijo 51', () {
      expect(conNumero('987 654 321').numeroWhatsapp, '51987654321');
    });

    test('acepta el número con +51 y guiones', () {
      expect(conNumero('+51 987-654-321').numeroWhatsapp, '51987654321');
      expect(conNumero('51987654321').numeroWhatsapp, '51987654321');
    });

    test('acepta un número de otro país si empieza con +', () {
      expect(conNumero('+49 151 2345 6789').numeroWhatsapp, '4915123456789');
    });

    test('un texto que no es número no abre WhatsApp', () {
      expect(conNumero('[número]').numeroWhatsapp, isNull);
      expect(conNumero('073 123456').numeroWhatsapp, isNull);
      expect(conNumero('').enlaceWhatsapp('Hola'), isNull);
    });
  });

  test('el enlace abre WhatsApp con el mensaje ya escrito', () {
    final enlace = conNumero('987 654 321').enlaceWhatsapp('Hola, ¿hay cupo?');

    expect(enlace?.host, 'wa.me');
    expect(enlace?.path, '/51987654321');
    expect(enlace?.queryParameters['text'], 'Hola, ¿hay cupo?');
  });
}
