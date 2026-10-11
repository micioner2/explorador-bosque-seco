import 'package:explorador_bosque_seco/features/reservas/domain/reserva.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ahora = DateTime(2026, 10, 10, 12);

  Reserva reserva({
    String nombre = 'Carmen Seminario',
    String? telefono,
    DateTime? fechaHora,
    int personas = 4,
  }) => Reserva.nueva(
    id: 'r1',
    asociacionId: 'a1',
    nombreContacto: nombre,
    telefono: telefono,
    fechaHora: fechaHora ?? DateTime(2026, 10, 10, 15),
    personas: personas,
    ahora: ahora,
  );

  group('al anotarla (R13)', () {
    test('queda pendiente, sin reprogramaciones', () {
      final nueva = reserva();

      expect(nueva.estado, EstadoReserva.pendiente);
      expect(nueva.pendiente, isTrue);
      expect(nueva.reprogramaciones, 0);
    });

    test('limpia el nombre y deja vacío el celular si no se escribió', () {
      final nueva = reserva(nombre: '  Diego Flores ', telefono: '   ');

      expect(nueva.nombreContacto, 'Diego Flores');
      expect(nueva.telefono, isNull);
    });

    test('necesita el nombre de quien reserva', () {
      expect(() => reserva(nombre: '  '), throwsArgumentError);
    });

    test('necesita entre 1 y ${Reserva.maxPersonas} personas', () {
      expect(() => reserva(personas: 0), throwsArgumentError);
      expect(
        () => reserva(personas: Reserva.maxPersonas + 1),
        throwsArgumentError,
      );
      expect(reserva(personas: 1).personas, 1);
    });

    test('no puede ser para una hora que ya pasó', () {
      expect(
        () => reserva(fechaHora: DateTime(2026, 10, 10, 11, 59)),
        throwsArgumentError,
      );
      // La hora actual, al minuto, todavía vale.
      expect(reserva(fechaHora: ahora).fechaHora, ahora);
    });
  });

  group('retrasada y no llegó', () {
    test('se retrasa cuando pasa su hora sin que llegue el grupo', () {
      final deLasTres = reserva();

      expect(deLasTres.retrasada(DateTime(2026, 10, 10, 14, 59)), isFalse);
      expect(deLasTres.retrasada(DateTime(2026, 10, 10, 15, 1)), isTrue);
      expect(deLasTres.noLlego(DateTime(2026, 10, 10, 23)), isFalse);
    });

    test('al día siguiente cuenta como que no llegó', () {
      expect(reserva().noLlego(DateTime(2026, 10, 11, 8)), isTrue);
    });

    test('una reserva cancelada no está retrasada', () {
      final cancelada = reserva().cancelar();

      expect(cancelada.retrasada(DateTime(2026, 10, 11)), isFalse);
      expect(cancelada.noLlego(DateTime(2026, 10, 11)), isFalse);
    });
  });

  group('reprogramar (R14)', () {
    test('cambia el día, la hora y las personas y cuenta el cambio', () {
      final cambiada = reserva().reprogramar(
        fechaHora: DateTime(2026, 10, 12, 9),
        personas: 6,
        ahora: ahora,
      );

      expect(cambiada.fechaHora, DateTime(2026, 10, 12, 9));
      expect(cambiada.personas, 6);
      expect(cambiada.reprogramaciones, 1);
      expect(cambiada.pendiente, isTrue);
    });

    test('no se puede mover a una hora que ya pasó', () {
      expect(
        () => reserva().reprogramar(
          fechaHora: DateTime(2026, 10, 10, 9),
          personas: 4,
          ahora: ahora,
        ),
        throwsArgumentError,
      );
    });

    test('un grupo que no llegó se puede reprogramar desde hoy', () {
      final deAyer = Reserva(
        id: 'r0',
        asociacionId: 'a1',
        nombreContacto: 'Paola Ríos',
        fechaHora: DateTime(2026, 10, 9, 9),
        personas: 2,
      );

      final cambiada = deAyer.reprogramar(
        fechaHora: DateTime(2026, 10, 10, 16),
        personas: 2,
        ahora: ahora,
      );

      expect(cambiada.noLlego(ahora), isFalse);
    });

    test('una reserva cancelada ya no se reprograma', () {
      expect(
        () => reserva().cancelar().reprogramar(
          fechaHora: DateTime(2026, 10, 12, 9),
          personas: 4,
          ahora: ahora,
        ),
        throwsStateError,
      );
    });
  });

  group('cancelar (R14)', () {
    test('deja de esperarse al grupo', () {
      expect(reserva().cancelar().estado, EstadoReserva.cancelada);
    });

    test('no se cancela dos veces', () {
      expect(() => reserva().cancelar().cancelar(), throwsStateError);
    });
  });

  group('ingreso del grupo (R15)', () {
    test('la reserva queda ligada a la visita registrada', () {
      final ingresada = reserva().registrarIngreso('v9');

      expect(ingresada.estado, EstadoReserva.ingresada);
      expect(ingresada.visitaId, 'v9');
    });

    test('se convierte en ingreso una sola vez', () {
      expect(
        () => reserva().registrarIngreso('v9').registrarIngreso('v10'),
        throwsStateError,
      );
    });

    test('una reserva cancelada no puede ingresar', () {
      expect(
        () => reserva().cancelar().registrarIngreso('v9'),
        throwsStateError,
      );
    });

    test('una ingresada no se cancela ni se reprograma', () {
      final ingresada = reserva().registrarIngreso('v9');

      expect(ingresada.cancelar, throwsStateError);
      expect(
        () => ingresada.reprogramar(
          fechaHora: DateTime(2026, 10, 12, 9),
          personas: 4,
          ahora: ahora,
        ),
        throwsStateError,
      );
    });
  });
}
