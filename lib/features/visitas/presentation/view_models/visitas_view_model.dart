import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/reloj.dart';
import '../../data/visitas_repository_demo.dart';
import '../../domain/resumen_del_dia.dart';
import '../../domain/visita.dart';

/// Estado y acciones del modo asociación: visitas del día.
class VisitasViewModel extends Notifier<List<Visita>> {
  DateTime get _ahora => ref.read(relojProvider)();

  @override
  List<Visita> build() {
    final hoy = ref.watch(relojProvider)();
    return ref.watch(visitasRepositoryProvider).visitasDelDia(hoy);
  }

  /// Registra la visita de un grupo: una sola visita (y un solo QR) para
  /// todos sus integrantes. Lanza [ArgumentError] si los datos no son
  /// válidos (las reglas viven en [Visita]).
  Visita registrar({
    required Iterable<Visitante> integrantes,
    required Iterable<Actividad> actividades,
    Duration duracionPrevista = const Duration(hours: 8),
  }) {
    final entrada = _ahora;
    final visita = Visita(
      id: 'v-${entrada.microsecondsSinceEpoch}',
      asociacionId: 'demo',
      integrantes: integrantes,
      actividades: actividades,
      fechaEntrada: entrada,
      salidaPrevista: entrada.add(duracionPrevista),
    );
    state = [...state, visita];
    return visita;
  }

  void marcarSalida(String visitaId) {
    state = [
      for (final visita in state)
        visita.id == visitaId ? visita.marcarSalida(_ahora) : visita,
    ];
  }
}

final visitasViewModelProvider =
    NotifierProvider<VisitasViewModel, List<Visita>>(VisitasViewModel.new);

/// Resumen derivado para la pantalla "Hoy".
final resumenDelDiaProvider = Provider<ResumenDelDia>(
  (ref) => ResumenDelDia.calcular(
    ref.watch(visitasViewModelProvider),
    ref.watch(relojProvider)(),
  ),
);
