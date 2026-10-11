import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/reloj.dart';
import '../../../puntos/presentation/view_models/pasaporte_view_model.dart';
import '../../../sesion/presentation/view_models/sesion_view_model.dart';
import '../../../visitas/presentation/view_models/visitas_view_model.dart';
import '../../data/cierres_repository_local.dart';
import '../../domain/cierre_dia.dart';
import '../../domain/reporte_diario.dart';

/// Reporte del día calculado a partir de las visitas y escaneos actuales.
final reporteViewModelProvider = Provider<ReporteDiario>(
  (ref) => ReporteDiario.calcular(
    dia: ref.watch(relojProvider)(),
    visitas: ref.watch(visitasViewModelProvider),
    escaneos: ref.watch(pasaporteViewModelProvider).escaneos,
  ),
);

/// Cierre del día de hoy de la asociación, o `null` si aún no se cerró.
class CierreViewModel extends Notifier<CierreDia?> {
  @override
  CierreDia? build() {
    final cuenta = ref.watch(sesionViewModelProvider.select((s) => s.cuenta));
    if (cuenta == null) return null;
    return ref
        .watch(cierresRepositoryProvider)
        .cierreDe(ref.watch(relojProvider)(), cuenta.asociacionId);
  }

  /// Cierra el día (o actualiza el cierre) a nombre del guía de la sesión.
  /// Lanza [StateError] si no hay guía elegido.
  CierreDia cerrarDia() {
    final (:cuenta, :guia) = ref.read(sesionViewModelProvider).quienRegistra();
    final cierre = CierreDia.desde(
      ref.read(reporteViewModelProvider),
      asociacionId: cuenta.asociacionId,
      cerradoPor: guia.nombre,
      ahora: ref.read(relojProvider)(),
    );
    state = cierre;
    ref.read(cierresRepositoryProvider).guardar(cierre);
    return cierre;
  }
}

final cierreViewModelProvider = NotifierProvider<CierreViewModel, CierreDia?>(
  CierreViewModel.new,
);
