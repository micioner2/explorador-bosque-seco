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

    // Documentos inventados para la demostración.
    var dni = 45120300;
    Visitante persona(String nombre, int edad, Procedencia procedencia) =>
        Visitante(
          nombre: nombre,
          documento: procedencia == Procedencia.extranjero
              ? 'C01X00T47'
              : '${dni++}',
          edad: edad,
          procedencia: procedencia,
          pais: 'Alemania',
        );

    return [
      Visita(
        id: 'v1',
        asociacionId: 'demo',
        integrantes: [
          persona('Ana Torres', 34, Procedencia.piura),
          persona('Carlos Torres', 36, Procedencia.piura),
          persona('Lucía Torres', 12, Procedencia.piura),
          persona('Mateo Torres', 9, Procedencia.piura),
        ],
        actividades: const [Actividad.senderismo, Actividad.fotografia],
        fechaEntrada: a(8),
        salidaPrevista: a(16),
        guiaId: 'g1',
        nombreGuia: 'María Quispe',
      ),
      Visita(
        id: 'v2',
        asociacionId: 'demo',
        integrantes: [
          persona('Luis Paredes', 27, Procedencia.lima),
          persona('Sofía Rojas', 26, Procedencia.lima),
        ],
        actividades: const [Actividad.aves],
        fechaEntrada: a(6, 30),
        salidaPrevista: a(18),
        guiaId: 'g2',
        nombreGuia: 'Juan Chunga',
      ),
      Visita(
        id: 'v3',
        asociacionId: 'demo',
        integrantes: [
          persona('Jorge Ramírez', 52, Procedencia.otraRegion),
          persona('Elena Ramírez', 49, Procedencia.otraRegion),
          persona('Emma Schmidt', 31, Procedencia.extranjero),
        ],
        actividades: const [Actividad.fotografia],
        fechaEntrada: a(7),
        salidaPrevista: a(11),
        guiaId: 'g1',
        nombreGuia: 'María Quispe',
      ),
    ];
  }
}

final visitasRepositoryProvider = Provider<VisitasRepository>(
  (ref) => const VisitasRepositoryDemo(),
);
