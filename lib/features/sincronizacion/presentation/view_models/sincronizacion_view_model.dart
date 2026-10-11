import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../puntos/presentation/view_models/pasaporte_view_model.dart';
import '../../../reportes/presentation/view_models/reporte_view_model.dart';
import '../../../sesion/presentation/view_models/sesion_view_model.dart';
import '../../../visitas/domain/visita.dart';
import '../../../visitas/presentation/view_models/visitas_view_model.dart';
import '../../data/confirmados_repository_local.dart';
import '../../data/red_repository_conectividad.dart';
import '../../data/sincronizacion_repository_supabase.dart';
import '../../domain/estado_sincronizacion.dart';
import '../../domain/sincronizacion_repository.dart';

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

/// Versión de un grupo para la sincronización: al marcar la salida cambia,
/// y el grupo vuelve a quedar pendiente para enviar la hora de salida.
String claveVisita(Visita visita) =>
    visita.salio ? '${visita.id}:salida' : visita.id;

/// Clave con la que se sincroniza el cierre de un día de una asociación
/// (la misma que devuelve el servidor al aceptarlo).
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
  return visitas
          .where((v) => !visitasConfirmadas.contains(claveVisita(v)))
          .length +
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

/// En qué está el envío al servidor.
enum EstadoEnvio { listo, enviando, sinTablas, sinConexion, rechazado }

/// Envía al servidor lo pendiente: los sellos del turista y, con la cuenta
/// de la asociación, los grupos y el cierre del día. Lo aceptado pasa a
/// confirmado; lo demás sigue pendiente y se reintenta luego.
class SincronizacionViewModel extends Notifier<EstadoEnvio> {
  @override
  EstadoEnvio build() => EstadoEnvio.listo;

  /// Devuelve cuántos registros aceptó el servidor, o `null` si no se pudo
  /// (sin servidor, ya enviando o con error: el estado dice cuál).
  Future<int?> sincronizar() async {
    final repositorio = ref.read(sincronizacionRepositoryProvider);
    if (repositorio == null || state == EstadoEnvio.enviando) return null;
    state = EstadoEnvio.enviando;
    try {
      var aceptados = 0;

      final pendientes = ref
          .read(pasaporteViewModelProvider)
          .escaneos
          .where((e) => !e.estaConfirmado);
      final escaneos = await repositorio.enviarEscaneos(pendientes);
      if (escaneos.isNotEmpty) {
        ref.read(pasaporteViewModelProvider.notifier).confirmar(escaneos);
      }
      aceptados += escaneos.length;

      // Los grupos y el cierre solo los envía la cuenta de la asociación.
      if (ref.read(sesionViewModelProvider).iniciada) {
        final confirmados = ref.read(confirmadosViewModelProvider.notifier);
        final yaEnviadas =
            ref.read(confirmadosViewModelProvider)[Colecciones.visitas] ??
            const {};
        final porEnviar = [
          for (final v in ref.read(visitasViewModelProvider))
            if (!yaEnviadas.contains(claveVisita(v))) v,
        ];
        final visitas = await repositorio.enviarVisitas(porEnviar);
        confirmados.confirmar(Colecciones.visitas, [
          for (final v in porEnviar)
            if (visitas.contains(v.id)) claveVisita(v),
        ]);
        aceptados += visitas.length;

        final cierre = ref.read(cierreViewModelProvider);
        if (cierre != null) {
          final cierres = await repositorio.enviarCierres([cierre]);
          confirmados.confirmar(Colecciones.cierres, cierres);
          aceptados += cierres.length;
        }
      }
      state = EstadoEnvio.listo;
      return aceptados;
    } on SincronizacionFallida catch (error) {
      state = switch (error.fallo) {
        FalloSincronizacion.sinTablas => EstadoEnvio.sinTablas,
        FalloSincronizacion.sinConexion => EstadoEnvio.sinConexion,
        FalloSincronizacion.rechazado => EstadoEnvio.rechazado,
      };
      return null;
    }
  }
}

final sincronizacionViewModelProvider =
    NotifierProvider<SincronizacionViewModel, EstadoEnvio>(
      SincronizacionViewModel.new,
    );

/// Se muestra "Sincronizar ahora": hay servidor y tiene las tablas.
final sincronizacionDisponibleProvider = Provider<bool>(
  (ref) =>
      ref.watch(sincronizacionRepositoryProvider) != null &&
      ref.watch(sincronizacionViewModelProvider) != EstadoEnvio.sinTablas,
);
