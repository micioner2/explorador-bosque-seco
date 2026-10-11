import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../mapa/presentation/view_models/mapa_view_model.dart';
import '../../../puntos/domain/cupon.dart';
import '../../../puntos/domain/pasaporte.dart';
import '../../../puntos/presentation/view_models/pasaporte_view_model.dart';
import '../../../sesion/presentation/view_models/sesion_view_model.dart';
import '../../data/vinculo_repository_local.dart';
import '../../domain/lectura_qr.dart';
import '../../domain/resultado_escaneo.dart';

/// Grupo (visita) al que está vinculado este celular, o `null` si el
/// turista aún no escaneó el QR que le muestra el guía.
class VinculoViewModel extends Notifier<String?> {
  @override
  String? build() => ref.watch(vinculoRepositoryProvider).visitaVinculada();

  void vincular(String visitaId) {
    state = visitaId;
    ref.read(vinculoRepositoryProvider).vincular(visitaId);
  }
}

final vinculoViewModelProvider = NotifierProvider<VinculoViewModel, String?>(
  VinculoViewModel.new,
);

/// Procesa lo que lee la cámara (o el código escrito a mano). Todo ocurre
/// en el celular: funciona en modo avión.
class EscaneoViewModel extends Notifier<ResultadoEscaneo?> {
  /// Último resultado, que la pantalla muestra hasta el siguiente escaneo.
  @override
  ResultadoEscaneo? build() => null;

  ResultadoEscaneo procesar(String texto) {
    final resultado = _procesar(LecturaQr.desde(texto));
    state = resultado;
    return resultado;
  }

  ResultadoEscaneo _procesar(LecturaQr lectura) {
    switch (lectura) {
      case QrDeGrupo(:final visitaId):
        final vinculo = ref.read(vinculoViewModelProvider.notifier);
        final yaEstaba = ref.read(vinculoViewModelProvider) == visitaId;
        if (!yaEstaba) vinculo.vincular(visitaId);
        return GrupoVinculado(yaEstaba: yaEstaba);
      case QrDePunto(:final puntoId):
        final ruta = ref.read(rutaActualProvider);
        final punto = ruta.puntos.where((p) => p.id == puntoId).firstOrNull;
        if (punto == null) return const PuntoAjeno();
        final visitaId = ref.read(vinculoViewModelProvider);
        if (visitaId == null) return FaltaGrupo(punto);
        final registro = ref
            .read(pasaporteViewModelProvider.notifier)
            .registrarEscaneo(visitaId: visitaId, puntoId: punto.id);
        return switch (registro) {
          PuntoGanado() => SelloGanado(punto),
          PuntoYaRegistrado() => SelloRepetido(punto),
        };
      case QrDeCupon(:final id, :final productoId, :final porcentaje):
        // Solo el puesto de control valida cupones.
        if (!ref.read(sesionViewModelProvider).iniciada) {
          return const CuponDelTurista();
        }
        final validacion = ref
            .read(cuponesUsadosViewModelProvider.notifier)
            .validar(id: id, productoId: productoId, porcentaje: porcentaje);
        final producto = ref
            .read(productosProvider)
            .where((p) => p.id == productoId)
            .firstOrNull;
        return CuponLeido(
          nombreProducto: producto?.nombre ?? productoId,
          porcentaje: porcentaje,
          valido: validacion is CuponValido,
        );
      case QrDesconocido():
        return const QrAjeno();
    }
  }
}

final escaneoViewModelProvider =
    NotifierProvider<EscaneoViewModel, ResultadoEscaneo?>(EscaneoViewModel.new);
