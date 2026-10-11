import '../domain/visita.dart';

/// Visitas de demostración, calculadas a partir de la hora actual para que
/// la demo se vea igual a cualquier hora: dos grupos dentro de su horario y
/// uno que debió salir hace 30 minutos (alerta "sigue dentro"). Se usan
/// cuando la app se compila sin servidor (ver `VisitasRepositoryLocal`).
class VisitasRepositoryDemo {
  const VisitasRepositoryDemo();

  /// Minutos que lleva atrasado el grupo de la alerta.
  static const atraso = Duration(minutes: 30);

  List<Visita> visitasDe(DateTime ahora) {
    DateTime hace(int minutos) => ahora.subtract(Duration(minutes: minutos));
    DateTime en(int minutos) => ahora.add(Duration(minutes: minutos));

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
        fechaEntrada: hace(180),
        salidaPrevista: en(300),
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
        fechaEntrada: hace(90),
        salidaPrevista: en(360),
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
        fechaEntrada: hace(300),
        salidaPrevista: ahora.subtract(atraso),
        guiaId: 'g1',
        nombreGuia: 'María Quispe',
      ),
    ];
  }
}
