import 'reserva.dart';

/// Reservas de un día, en orden de llegada.
class DiaDeReservas {
  DiaDeReservas(this.dia, Iterable<Reserva> reservas)
    : reservas = List.unmodifiable(reservas);

  final DateTime dia;
  final List<Reserva> reservas;

  int get personas => reservas.fold(0, (suma, r) => suma + r.personas);
}

/// Agenda del puesto de control: solo las reservas pendientes, ordenadas
/// por hora. Las canceladas y las que ya ingresaron no aparecen.
class AgendaReservas {
  const AgendaReservas._({
    required this.ahora,
    required this.sinLlegar,
    required this.deHoy,
    required this.proximas,
  });

  factory AgendaReservas.calcular(Iterable<Reserva> reservas, DateTime ahora) {
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final pendientes = [
      for (final reserva in reservas)
        if (reserva.pendiente) reserva,
    ]..sort((a, b) => a.fechaHora.compareTo(b.fechaHora));

    final proximas = <DiaDeReservas>[];
    for (final reserva in pendientes) {
      final fecha = reserva.fechaHora;
      final dia = DateTime(fecha.year, fecha.month, fecha.day);
      if (!dia.isAfter(hoy)) continue;
      if (proximas.isNotEmpty && proximas.last.dia == dia) {
        proximas.last = DiaDeReservas(dia, [
          ...proximas.last.reservas,
          reserva,
        ]);
      } else {
        proximas.add(DiaDeReservas(dia, [reserva]));
      }
    }

    return AgendaReservas._(
      ahora: ahora,
      sinLlegar: List.unmodifiable(pendientes.where((r) => r.noLlego(ahora))),
      deHoy: DiaDeReservas(hoy, pendientes.where((r) => r.esDelDia(hoy))),
      proximas: List.unmodifiable(proximas),
    );
  }

  /// Momento en que se armó la agenda (para saber qué está retrasado).
  final DateTime ahora;

  /// Reservas de días anteriores cuyo grupo nunca llegó: hay que
  /// reprogramarlas o cancelarlas.
  final List<Reserva> sinLlegar;

  /// Las que llegan hoy, incluidas las retrasadas.
  final DiaDeReservas deHoy;

  /// Las de los días siguientes, agrupadas por día.
  final List<DiaDeReservas> proximas;

  bool get vacia =>
      sinLlegar.isEmpty && deHoy.reservas.isEmpty && proximas.isEmpty;
}
