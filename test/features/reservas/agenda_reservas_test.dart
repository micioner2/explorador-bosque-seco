import 'package:explorador_bosque_seco/features/reservas/domain/agenda_reservas.dart';
import 'package:explorador_bosque_seco/features/reservas/domain/reserva.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ahora = DateTime(2026, 10, 10, 12);

  Reserva reserva(String id, DateTime fechaHora, {int personas = 2}) => Reserva(
    id: id,
    asociacionId: 'a1',
    nombreContacto: 'Contacto $id',
    fechaHora: fechaHora,
    personas: personas,
  );

  test('sin reservas pendientes, la agenda está vacía', () {
    final cancelada = reserva('r1', DateTime(2026, 10, 10, 15)).cancelar();
    final ingresada = reserva(
      'r2',
      DateTime(2026, 10, 10, 9),
    ).registrarIngreso('v1');

    final agenda = AgendaReservas.calcular([cancelada, ingresada], ahora);

    expect(agenda.vacia, isTrue);
  });

  test('las de hoy van por hora de llegada, incluidas las retrasadas', () {
    final agenda = AgendaReservas.calcular([
      reserva('tarde', DateTime(2026, 10, 10, 15), personas: 4),
      reserva('retrasada', DateTime(2026, 10, 10, 10, 30)),
    ], ahora);

    expect(agenda.deHoy.reservas.map((r) => r.id), ['retrasada', 'tarde']);
    expect(agenda.deHoy.personas, 6);
  });

  test('los próximos días se agrupan por día, en orden', () {
    final agenda = AgendaReservas.calcular([
      reserva('pasado', DateTime(2026, 10, 12, 9)),
      reserva('manana-tarde', DateTime(2026, 10, 11, 16)),
      reserva('manana', DateTime(2026, 10, 11, 8), personas: 25),
    ], ahora);

    expect(agenda.proximas.map((d) => d.dia), [
      DateTime(2026, 10, 11),
      DateTime(2026, 10, 12),
    ]);
    expect(agenda.proximas.first.reservas.map((r) => r.id), [
      'manana',
      'manana-tarde',
    ]);
    expect(agenda.proximas.first.personas, 27);
    expect(agenda.deHoy.reservas, isEmpty);
  });

  test('las de días anteriores que no llegaron van aparte', () {
    final agenda = AgendaReservas.calcular([
      reserva('ayer', DateTime(2026, 10, 9, 9)),
      reserva('hoy', DateTime(2026, 10, 10, 15)),
    ], ahora);

    expect(agenda.sinLlegar.single.id, 'ayer');
    expect(agenda.deHoy.reservas.single.id, 'hoy');
    expect(agenda.vacia, isFalse);
  });
}
