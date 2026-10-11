import 'package:explorador_bosque_seco/features/visitas/domain/resumen_del_dia.dart';
import 'package:explorador_bosque_seco/features/visitas/domain/visita.dart';
import 'package:flutter_test/flutter_test.dart';

Visita visita(String id, {required int grupo, required int salidaHora}) =>
    Visita(
      id: id,
      asociacionId: 'a1',
      integrantes: [
        for (var i = 1; i <= grupo; i++)
          Visitante(
            nombre: 'Persona $i del grupo $id',
            documento: '40000000',
            edad: 30,
            procedencia: Procedencia.piura,
          ),
      ],
      actividades: const [Actividad.senderismo],
      fechaEntrada: DateTime(2026, 10, 10, 7),
      salidaPrevista: DateTime(2026, 10, 10, salidaHora),
    );

void main() {
  final ahora = DateTime(2026, 10, 10, 12);

  test('separa personas dentro, que salieron y grupos atrasados', () {
    final visitas = [
      visita('a', grupo: 4, salidaHora: 16),
      visita('b', grupo: 3, salidaHora: 11),
      visita(
        'c',
        grupo: 2,
        salidaHora: 10,
      ).marcarSalida(DateTime(2026, 10, 10, 9, 45)),
    ];

    final resumen = ResumenDelDia.calcular(visitas, ahora);

    expect(resumen.personasDentro, 7);
    expect(resumen.personasQueSalieron, 2);
    expect(resumen.personasTotal, 9);
    expect(resumen.atrasadas.map((v) => v.id), ['b']);
  });

  test('sin visitas el resumen queda en cero', () {
    final resumen = ResumenDelDia.calcular(const [], ahora);

    expect(resumen.personasTotal, 0);
    expect(resumen.dentro, isEmpty);
  });
}
