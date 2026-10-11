import '../../puntos/domain/escaneo.dart';
import '../../visitas/domain/visita.dart';

/// Rango de edad usado en el reporte: menos de 18, 18 a 29, 30 a 44,
/// 45 a 59 y 60 o más.
enum RangoEdad {
  menores,
  de18a29,
  de30a44,
  de45a59,
  mayores;

  static RangoEdad de(int edad) {
    if (edad < 18) return RangoEdad.menores;
    if (edad < 30) return RangoEdad.de18a29;
    if (edad < 45) return RangoEdad.de30a44;
    if (edad < 60) return RangoEdad.de45a59;
    return RangoEdad.mayores;
  }
}

/// Lo que registró un guía en el día.
class ResumenGuia {
  const ResumenGuia({
    required this.nombreGuia,
    required this.grupos,
    required this.personas,
  });

  final String nombreGuia;
  final int grupos;
  final int personas;

  @override
  bool operator ==(Object other) =>
      other is ResumenGuia &&
      other.nombreGuia == nombreGuia &&
      other.grupos == grupos &&
      other.personas == personas;

  @override
  int get hashCode => Object.hash(nombreGuia, grupos, personas);
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
    this.porGuia = const [],
    this.gruposSinSalida = 0,
  });

  /// Calcula el reporte de [dia] a partir de las visitas y escaneos.
  ///
  /// Los visitantes se cuentan por persona: cada integrante de un grupo
  /// suma con su propia edad y procedencia.
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
    final gruposPorGuia = <String, int>{};
    final personasPorGuia = <String, int>{};
    var gruposSinSalida = 0;

    for (final visita in delDia) {
      totalGrupos++;
      totalVisitantes += visita.tamanoGrupo;
      idsVisitas.add(visita.id);
      if (!visita.salio) gruposSinSalida++;
      final guia = visita.nombreGuia ?? sinGuia;
      gruposPorGuia.update(guia, (n) => n + 1, ifAbsent: () => 1);
      personasPorGuia.update(
        guia,
        (n) => n + visita.tamanoGrupo,
        ifAbsent: () => visita.tamanoGrupo,
      );
      for (final integrante in visita.integrantes) {
        porProcedencia.update(
          integrante.procedencia,
          (n) => n + 1,
          ifAbsent: () => 1,
        );
        porRangoEdad.update(
          RangoEdad.de(integrante.edad),
          (n) => n + 1,
          ifAbsent: () => 1,
        );
      }
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

    final porGuia =
        <ResumenGuia>[
          for (final MapEntry(key: guia, value: grupos)
              in gruposPorGuia.entries)
            ResumenGuia(
              nombreGuia: guia,
              grupos: grupos,
              personas: personasPorGuia[guia]!,
            ),
        ]..sort((a, b) {
          final porPersonas = b.personas.compareTo(a.personas);
          return porPersonas != 0
              ? porPersonas
              : a.nombreGuia.compareTo(b.nombreGuia);
        });

    return ReporteDiario(
      dia: DateTime(dia.year, dia.month, dia.day),
      totalVisitantes: totalVisitantes,
      totalGrupos: totalGrupos,
      porProcedencia: Map.unmodifiable(porProcedencia),
      porRangoEdad: Map.unmodifiable(porRangoEdad),
      puntosMasVisitados: List.unmodifiable(ranking),
      porGuia: List.unmodifiable(porGuia),
      gruposSinSalida: gruposSinSalida,
    );
  }

  /// Nombre con el que se agrupan las visitas que no tienen guía.
  static const sinGuia = '—';

  final DateTime dia;
  final int totalVisitantes;
  final int totalGrupos;
  final Map<Procedencia, int> porProcedencia;
  final Map<RangoEdad, int> porRangoEdad;

  /// Pares (puntoId, cantidad de visitas) de mayor a menor.
  final List<MapEntry<String, int>> puntosMasVisitados;

  /// Grupos y personas que registró cada guía, de más a menos personas.
  final List<ResumenGuia> porGuia;

  /// Grupos sin salida marcada: siguen en el bosque o acampan.
  final int gruposSinSalida;

  static bool _mismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
