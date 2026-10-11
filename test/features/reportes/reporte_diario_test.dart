import 'package:explorador_bosque_seco/features/puntos/domain/escaneo.dart';
import 'package:explorador_bosque_seco/features/reportes/domain/reporte_diario.dart';
import 'package:explorador_bosque_seco/features/visitas/domain/visita.dart';
import 'package:flutter_test/flutter_test.dart';

final dia = DateTime(2026, 10, 10);

/// Grupo con un integrante por cada edad indicada, todos de la misma
/// [procedencia] salvo los que se pasen en [otros].
Visita visita(
  String id, {
  required Procedencia procedencia,
  required List<int> edades,
  List<Visitante> otros = const [],
  DateTime? entrada,
}) {
  final e = entrada ?? DateTime(2026, 10, 10, 8);
  return Visita(
    id: id,
    asociacionId: 'a1',
    integrantes: [
      for (final edad in edades)
        Visitante(
          nombre: 'Persona de $edad años ($id)',
          edad: edad,
          procedencia: procedencia,
        ),
      ...otros,
    ],
    actividades: const [Actividad.senderismo],
    fechaEntrada: e,
    salidaPrevista: e.add(const Duration(hours: 6)),
  );
}

Escaneo escaneo(String id, String visitaId, String puntoId) => Escaneo(
  id: id,
  visitaId: visitaId,
  puntoId: puntoId,
  fecha: DateTime(2026, 10, 10, 10),
);

void main() {
  final visitas = [
    // Familia de Piura con dos menores y una invitada del extranjero.
    visita(
      'v1',
      procedencia: Procedencia.piura,
      edades: [34, 36, 12],
      otros: [
        Visitante(
          nombre: 'Emma Schmidt',
          edad: 31,
          procedencia: Procedencia.extranjero,
        ),
      ],
    ),
    visita('v2', procedencia: Procedencia.lima, edades: [25, 27]),
    visita('v3', procedencia: Procedencia.piura, edades: [61]),
    visita(
      'ayer',
      procedencia: Procedencia.otraRegion,
      edades: [40, 41, 42, 43, 44],
      entrada: DateTime(2026, 10, 9, 8),
    ),
  ];

  final escaneos = [
    escaneo('e1', 'v1', 'pozas'),
    escaneo('e2', 'v1', 'pozas'),
    escaneo('e3', 'v2', 'pozas'),
    escaneo('e4', 'v2', 'caida'),
    escaneo('e5', 'ayer', 'caida'),
  ];

  final reporte = ReporteDiario.calcular(
    dia: dia,
    visitas: visitas,
    escaneos: escaneos,
  );

  test('cuenta personas y grupos solo del día', () {
    expect(reporte.totalVisitantes, 7);
    expect(reporte.totalGrupos, 3);
  });

  test('cuenta la procedencia de cada integrante, no la del grupo', () {
    expect(reporte.porProcedencia[Procedencia.piura], 4);
    expect(reporte.porProcedencia[Procedencia.lima], 2);
    expect(reporte.porProcedencia[Procedencia.extranjero], 1);
    expect(reporte.porProcedencia.containsKey(Procedencia.otraRegion), isFalse);
  });

  test('cuenta la edad de cada integrante en su rango', () {
    expect(reporte.porRangoEdad[RangoEdad.menores], 1);
    expect(reporte.porRangoEdad[RangoEdad.de18a29], 2);
    expect(reporte.porRangoEdad[RangoEdad.de30a44], 3);
    expect(reporte.porRangoEdad[RangoEdad.mayores], 1);
    expect(reporte.porRangoEdad.containsKey(RangoEdad.de45a59), isFalse);
  });

  test('procedencias y edades suman el total de visitantes', () {
    int sumar(Iterable<int> valores) => valores.fold(0, (a, b) => a + b);

    expect(sumar(reporte.porProcedencia.values), reporte.totalVisitantes);
    expect(sumar(reporte.porRangoEdad.values), reporte.totalVisitantes);
  });

  test('ordena los puntos más visitados sin contar duplicados', () {
    expect(reporte.puntosMasVisitados.first.key, 'pozas');
    expect(reporte.puntosMasVisitados.first.value, 2);
    expect(reporte.puntosMasVisitados.last.key, 'caida');
    expect(reporte.puntosMasVisitados.last.value, 1);
  });

  test('clasifica las edades en el rango correcto', () {
    expect(RangoEdad.de(17), RangoEdad.menores);
    expect(RangoEdad.de(18), RangoEdad.de18a29);
    expect(RangoEdad.de(44), RangoEdad.de30a44);
    expect(RangoEdad.de(59), RangoEdad.de45a59);
    expect(RangoEdad.de(60), RangoEdad.mayores);
  });
}
