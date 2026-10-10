import '../../puntos/domain/escaneo.dart';
import '../../visitas/domain/visita.dart';

/// Rango de edad usado en el reporte.
enum RangoEdad {
  menores('Menos de 18'),
  de18a29('18 a 29'),
  de30a44('30 a 44'),
  de45a59('45 a 59'),
  mayores('60 o más');

  const RangoEdad(this.etiqueta);

  final String etiqueta;

  static RangoEdad de(int edad) {
    if (edad < 18) return RangoEdad.menores;
    if (edad < 30) return RangoEdad.de18a29;
    if (edad < 45) return RangoEdad.de30a44;
    if (edad < 60) return RangoEdad.de45a59;
    return RangoEdad.mayores;
  }
}

/// Resumen del día para el cierre de la asociación (base del PDF).
class ReporteDiario {
  const ReporteDiario({
    required this.dia,
    required this.totalVisitantes,
    required this.totalGrupos,
    required this.porProcedencia,
    required this.porRangoEdad,
    required this.puntosMasVisitados,
  });

  /// Calcula el reporte de [dia] a partir de las visitas y escaneos.
  ///
  /// Los visitantes se cuentan por persona (tamaño del grupo). La edad y
  /// procedencia son las del responsable del grupo.
  factory ReporteDiario.calcular({
    required DateTime dia,
    required Iterable<Visita> visitas,
    required Iterable<Escaneo> escaneos,
  }) {
    final delDia = visitas.where((v) => _mismoDia(v.fechaEntrada, dia));

    final porProcedencia = <Procedencia, int>{};
    final porRangoEdad = <RangoEdad, int>{};
    var totalVisitantes = 0;
    var totalGrupos = 0;
    final idsVisitas = <String>{};

    for (final visita in delDia) {
      totalGrupos++;
      totalVisitantes += visita.tamanoGrupo;
      idsVisitas.add(visita.id);
      porProcedencia.update(
        visita.procedencia,
        (n) => n + visita.tamanoGrupo,
        ifAbsent: () => visita.tamanoGrupo,
      );
      porRangoEdad.update(
        RangoEdad.de(visita.edad),
        (n) => n + 1,
        ifAbsent: () => 1,
      );
    }

    final porPunto = <String, int>{};
    final vistos = <String>{};
    for (final escaneo in escaneos) {
      if (!idsVisitas.contains(escaneo.visitaId)) continue;
      if (!vistos.add(escaneo.clave)) continue;
      porPunto.update(escaneo.puntoId, (n) => n + 1, ifAbsent: () => 1);
    }
    final ranking = porPunto.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ReporteDiario(
      dia: DateTime(dia.year, dia.month, dia.day),
      totalVisitantes: totalVisitantes,
      totalGrupos: totalGrupos,
      porProcedencia: Map.unmodifiable(porProcedencia),
      porRangoEdad: Map.unmodifiable(porRangoEdad),
      puntosMasVisitados: List.unmodifiable(ranking),
    );
  }

  final DateTime dia;
  final int totalVisitantes;
  final int totalGrupos;
  final Map<Procedencia, int> porProcedencia;
  final Map<RangoEdad, int> porRangoEdad;

  /// Pares (puntoId, cantidad de visitas) de mayor a menor.
  final List<MapEntry<String, int>> puntosMasVisitados;

  static bool _mismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
