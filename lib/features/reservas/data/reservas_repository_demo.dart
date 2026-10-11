import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/reserva.dart';
import '../domain/reservas_repository.dart';

/// Reservas de demostración, relativas al día de hoy. Se reemplazan por las
/// de Supabase cuando exista su tabla.
class ReservasRepositoryDemo implements ReservasRepository {
  const ReservasRepositoryDemo();

  @override
  List<Reserva> reservas(DateTime hoy) {
    DateTime en(int dias, int hora, [int minuto = 0]) =>
        DateTime(hoy.year, hoy.month, hoy.day + dias, hora, minuto);

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
        fechaHora: en(0, 10, 30),
        personas: 2,
        guiaId: 'g1',
        nombreGuia: 'María Quispe',
      ),
      Reserva(
        id: 'r3',
        asociacionId: 'demo',
        nombreContacto: 'Carmen Seminario',
        telefono: '944 300 120',
        fechaHora: en(0, 15),
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

final reservasRepositoryProvider = Provider<ReservasRepository>(
  (ref) => const ReservasRepositoryDemo(),
);
