import 'visita.dart';

/// Resumen del puesto de control en un momento dado.
class ResumenDelDia {
  const ResumenDelDia({
    required this.dentro,
    required this.atrasadas,
    required this.personasDentro,
    required this.personasQueSalieron,
  });

  factory ResumenDelDia.calcular(Iterable<Visita> visitas, DateTime ahora) {
    final dentro = visitas.where((v) => !v.salio).toList(growable: false);
    final atrasadas = dentro
        .where((v) => v.sigueDentro(ahora))
        .toList(growable: false);
    final personasDentro = _personas(dentro);
    return ResumenDelDia(
      dentro: dentro,
      atrasadas: atrasadas,
      personasDentro: personasDentro,
      personasQueSalieron: _personas(visitas) - personasDentro,
    );
  }

  /// Grupos que siguen en el bosque.
  final List<Visita> dentro;

  /// Grupos que pasaron su hora de salida sin marcarla (alerta).
  final List<Visita> atrasadas;

  final int personasDentro;
  final int personasQueSalieron;

  int get personasTotal => personasDentro + personasQueSalieron;

  static int _personas(Iterable<Visita> visitas) =>
      visitas.fold(0, (total, v) => total + v.tamanoGrupo);
}
