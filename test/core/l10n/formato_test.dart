import 'package:explorador_bosque_seco/core/l10n/formato.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatearDistancia', () {
    test('menos de un kilómetro se muestra en metros', () {
      expect(formatearDistancia(850, 'es'), '850 m');
      expect(formatearDistancia(0, 'es'), '0 m');
    });

    test('desde un kilómetro usa km con un decimal como máximo', () {
      expect(formatearDistancia(1000, 'es'), '1 km');
      expect(formatearDistancia(1200, 'es'), '1,2 km');
      expect(formatearDistancia(4600, 'es'), '4,6 km');
    });

    test('en inglés el decimal va con punto', () {
      expect(formatearDistancia(1200, 'en'), '1.2 km');
    });
  });

  group('formatearDuracion', () {
    test('menos de una hora se muestra en minutos', () {
      expect(formatearDuracion(const Duration(minutes: 25)), '25 min');
    });

    test('horas exactas no muestran minutos', () {
      expect(formatearDuracion(const Duration(hours: 2)), '2 h');
    });

    test('combina horas y minutos', () {
      expect(formatearDuracion(const Duration(minutes: 110)), '1 h 50 min');
    });
  });
}
