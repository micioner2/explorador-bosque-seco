import 'package:explorador_bosque_seco/features/puntos/domain/escaneo.dart';
import 'package:explorador_bosque_seco/features/reportes/domain/reporte_diario.dart';
import 'package:explorador_bosque_seco/features/visitas/domain/visita.dart';
import 'package:flutter_test/flutter_test.dart';

final dia = DateTime(2026, 10, 10);

Visita visita(
  String id, {
  required Procedencia procedencia,
  required int edad,
  required int grupo,
  DateTime? entrada,
}) {
  final e = entrada ?? DateTime(2026, 10, 10, 8);
  return Visita(
    id: id,
    asociacionId: 'a1',
    nombreResponsable: 'Responsable $id',
    edad: edad,
    procedencia: procedencia,
    tamanoGrupo: grupo,
    actividad: Actividad.senderismo,
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
    visita('v1', procedencia: Procedencia.piura, edad: 34, grupo: 4),
    visita('v2', procedencia: Procedencia.lima, edad: 25, grupo: 2),
    visita('v3', procedencia: Procedencia.piura, edad: 61, grupo: 1),
    visita(
      'ayer',
      procedencia: Procedencia.extranjero,
      edad: 40,
      grupo: 5,
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

  test('agrupa visitantes por procedencia', () {
    expect(reporte.porProcedencia[Procedencia.piura], 5);
    expect(reporte.porProcedencia[Procedencia.lima], 2);
    expect(reporte.porProcedencia.containsKey(Procedencia.extranjero), isFalse);
  });

  test('agrupa responsables por rango de edad', () {
    expect(reporte.porRangoEdad[RangoEdad.de30a44], 1);
    expect(reporte.porRangoEdad[RangoEdad.de18a29], 1);
    expect(reporte.porRangoEdad[RangoEdad.mayores], 1);
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
