import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../puntos/presentation/view_models/pasaporte_view_model.dart';
import '../../../reportes/presentation/view_models/reporte_view_model.dart';
import '../../../visitas/presentation/view_models/visitas_view_model.dart';
import '../../data/confirmados_repository_local.dart';
import '../../data/red_repository_conectividad.dart';
import '../../domain/estado_sincronizacion.dart';

/// Colecciones que se sincronizan desde el puesto de control.
abstract final class Colecciones {
  static const visitas = 'visitas';
  static const cierres = 'cierres';
}

/// Si el celular tiene red ahora mismo; `null` mientras aún no responde.
///
/// Es un Notifier con su propia suscripción (y no un StreamProvider) para
/// que el estado siga al día aunque la pantalla que lo muestra esté en otra
/// pestaña.
class RedViewModel extends Notifier<bool?> {
  @override
  bool? build() {
    final suscripcion = ref
        .watch(redRepositoryProvider)
        .hayRed()
        .listen((conRed) => state = conRed, onError: (Object _) {});
    ref.onDispose(suscripcion.cancel);
    return null;
  }
}

final hayRedProvider = NotifierProvider<RedViewModel, bool?>(RedViewModel.new);

/// Ids que el servidor ya aceptó, por colección. La sincronización lo
/// actualiza al recibir la respuesta.
class ConfirmadosViewModel extends Notifier<Map<String, Set<String>>> {
  @override
  Map<String, Set<String>> build() {
    final repositorio = ref.watch(confirmadosRepositoryProvider);
    return {
      for (final coleccion in [Colecciones.visitas, Colecciones.cierres])
        coleccion: repositorio.confirmados(coleccion),
    };
  }

  void confirmar(String coleccion, Iterable<String> ids) {
    state = {
      ...state,
      coleccion: {...?state[coleccion], ...ids},
    };
    ref.read(confirmadosRepositoryProvider).confirmar(coleccion, ids);
  }
}

final confirmadosViewModelProvider =
    NotifierProvider<ConfirmadosViewModel, Map<String, Set<String>>>(
      ConfirmadosViewModel.new,
    );

/// Clave con la que se sincroniza el cierre de un día de una asociación.
String claveCierre(String asociacionId, DateTime dia) =>
    '$asociacionId:${dia.year}-${dia.month}-${dia.day}';

/// Registros del puesto de control que aún no llegan al servidor: grupos
/// del día y el cierre.
final pendientesPuestoProvider = Provider<int>((ref) {
  final confirmados = ref.watch(confirmadosViewModelProvider);
  final visitas = ref.watch(visitasViewModelProvider);
  final cierre = ref.watch(cierreViewModelProvider);
  final visitasConfirmadas = confirmados[Colecciones.visitas] ?? const {};
  final cierresConfirmados = confirmados[Colecciones.cierres] ?? const {};
  return visitas.where((v) => !visitasConfirmadas.contains(v.id)).length +
      (cierre == null ||
              cierresConfirmados.contains(
                claveCierre(cierre.asociacionId, cierre.dia),
              )
          ? 0
          : 1);
});

/// Sellos del turista que aún no llegan al servidor.
final pendientesTuristaProvider = Provider<int>(
  (ref) => ref.watch(pasaporteViewModelProvider).puntosPendientes,
);

/// Estado que muestra el aviso de conexión en el modo turista.
final estadoTuristaProvider = Provider<EstadoSincronizacion>(
  (ref) => EstadoSincronizacion.calcular(
    hayRed: ref.watch(hayRedProvider),
    pendientes: ref.watch(pendientesTuristaProvider),
  ),
);

/// Estado que muestra el aviso de conexión en el puesto de control.
final estadoPuestoProvider = Provider<EstadoSincronizacion>(
  (ref) => EstadoSincronizacion.calcular(
    hayRed: ref.watch(hayRedProvider),
    pendientes: ref.watch(pendientesPuestoProvider),
  ),
);
