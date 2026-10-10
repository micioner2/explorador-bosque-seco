import 'package:explorador_bosque_seco/features/visitas/domain/visita.dart';
import 'package:flutter_test/flutter_test.dart';

Visita visita({
  String nombre = 'Ana Torres',
  int edad = 34,
  int grupo = 4,
  DateTime? entrada,
  DateTime? salidaPrevista,
}) {
  final e = entrada ?? DateTime(2026, 10, 10, 8);
  return Visita(
    id: 'v1',
    asociacionId: 'a1',
    nombreResponsable: nombre,
    edad: edad,
    procedencia: Procedencia.piura,
    tamanoGrupo: grupo,
    actividad: Actividad.senderismo,
    fechaEntrada: e,
    salidaPrevista: salidaPrevista ?? e.add(const Duration(hours: 8)),
  );
}

void main() {
  group('Validaciones del registro', () {
    test('rechaza nombre vacío', () {
      expect(() => visita(nombre: '  '), throwsArgumentError);
    });

    test('rechaza edad fuera de rango', () {
      expect(() => visita(edad: -1), throwsArgumentError);
      expect(() => visita(edad: 150), throwsArgumentError);
    });

    test('rechaza grupo vacío', () {
      expect(() => visita(grupo: 0), throwsArgumentError);
    });

    test('la salida prevista debe ser posterior a la entrada', () {
      final entrada = DateTime(2026, 10, 10, 8);
      expect(
        () => visita(entrada: entrada, salidaPrevista: entrada),
        throwsArgumentError,
      );
    });
  });

  group('Alerta "sigue dentro"', () {
    final v = visita(
      entrada: DateTime(2026, 10, 10, 8),
      salidaPrevista: DateTime(2026, 10, 10, 16),
    );

    test('no alerta antes de la hora de salida', () {
      expect(v.sigueDentro(DateTime(2026, 10, 10, 15)), isFalse);
    });

    test('alerta si pasó la hora de salida y no marcó salida', () {
      expect(v.sigueDentro(DateTime(2026, 10, 10, 17)), isTrue);
    });

    test('no alerta si ya marcó su salida', () {
      final salio = v.marcarSalida(DateTime(2026, 10, 10, 15, 30));
      expect(salio.sigueDentro(DateTime(2026, 10, 10, 17)), isFalse);
    });

    test('no se puede marcar la salida dos veces', () {
      final salio = v.marcarSalida(DateTime(2026, 10, 10, 15));
      expect(
        () => salio.marcarSalida(DateTime(2026, 10, 10, 16)),
        throwsStateError,
      );
    });
  });
}
