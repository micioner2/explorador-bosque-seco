import '../domain/reserva.dart';

/// Reservas de demostración, calculadas a partir de la hora actual: una que
/// no llegó ayer, una retrasada, una que **llega en la próxima hora** y dos
/// de los próximos días. Se usan cuando la app se compila sin servidor.
class ReservasRepositoryDemo {
  const ReservasRepositoryDemo();

  /// Cuánto falta para que llegue la reserva de la próxima hora.
  static const llegaEn = Duration(minutes: 40);

  List<Reserva> reservasDe(DateTime ahora) {
    DateTime en(int dias, int hora, [int minuto = 0]) =>
        DateTime(ahora.year, ahora.month, ahora.day + dias, hora, minuto);

    return [
      Reserva(
        id: 'r1',
        asociacionId: 'demo',
        nombreContacto: 'Paola Ríos',
        telefono: '987 654 321',
        fechaHora: en(-1, 9),
        personas: 2,
        guiaId: 'g3',
        nombreGuia: 'Rosa Yarlequé',
      ),
      Reserva(
        id: 'r2',
        asociacionId: 'demo',
        nombreContacto: 'Diego Flores',
        telefono: '956 112 233',
        fechaHora: ahora.subtract(const Duration(minutes: 90)),
        personas: 2,
        guiaId: 'g1',
        nombreGuia: 'María Quispe',
      ),
      Reserva(
        id: 'r3',
        asociacionId: 'demo',
        nombreContacto: 'Carmen Seminario',
        telefono: '944 300 120',
        fechaHora: ahora.add(llegaEn),
        personas: 4,
        guiaId: 'g1',
        nombreGuia: 'María Quispe',
      ),
      Reserva(
        id: 'r4',
        asociacionId: 'demo',
        nombreContacto: 'Gabriela Ramos',
        fechaHora: en(1, 8),
        personas: 25,
        guiaId: 'g2',
        nombreGuia: 'Juan Chunga',
      ),
      Reserva(
        id: 'r5',
        asociacionId: 'demo',
        nombreContacto: 'Martín Vega',
        telefono: '912 445 778',
        fechaHora: en(2, 9),
        personas: 3,
        reprogramaciones: 1,
        guiaId: 'g2',
        nombreGuia: 'Juan Chunga',
      ),
    ];
  }
}
