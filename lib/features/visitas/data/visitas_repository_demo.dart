import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/visita.dart';
import '../domain/visitas_repository.dart';

/// Visitas de demostración. Se reemplazan por las registradas en el puesto
/// de control cuando se conecte el backend.
class VisitasRepositoryDemo implements VisitasRepository {
  const VisitasRepositoryDemo();

  @override
  List<Visita> visitasDelDia(DateTime dia) {
    DateTime a(int hora, [int minuto = 0]) =>
        DateTime(dia.year, dia.month, dia.day, hora, minuto);

    return [
      Visita(
        id: 'v1',
        asociacionId: 'demo',
        nombreResponsable: 'Ana Torres',
        edad: 34,
        procedencia: Procedencia.piura,
        tamanoGrupo: 4,
        actividad: Actividad.senderismo,
        fechaEntrada: a(8),
        salidaPrevista: a(16),
        guia: 'Guía 1',
      ),
      Visita(
        id: 'v2',
        asociacionId: 'demo',
        nombreResponsable: 'Luis Paredes',
        edad: 27,
        procedencia: Procedencia.lima,
        tamanoGrupo: 2,
        actividad: Actividad.aves,
        fechaEntrada: a(6, 30),
        salidaPrevista: a(18),
        guia: 'Guía 2',
      ),
      Visita(
        id: 'v3',
        asociacionId: 'demo',
        nombreResponsable: 'Grupo Ramírez',
        edad: 52,
        procedencia: Procedencia.otraRegion,
        tamanoGrupo: 3,
        actividad: Actividad.fotografia,
        fechaEntrada: a(7),
        salidaPrevista: a(11),
        guia: 'Guía 1',
      ),
    ];
  }
}

final visitasRepositoryProvider = Provider<VisitasRepository>(
  (ref) => const VisitasRepositoryDemo(),
);
