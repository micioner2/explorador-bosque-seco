import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/reloj.dart';
import '../../../puntos/presentation/view_models/pasaporte_view_model.dart';
import '../../../visitas/presentation/view_models/visitas_view_model.dart';
import '../../domain/reporte_diario.dart';

/// Reporte del día calculado a partir de las visitas y escaneos actuales.
final reporteViewModelProvider = Provider<ReporteDiario>(
  (ref) => ReporteDiario.calcular(
    dia: ref.watch(relojProvider)(),
    visitas: ref.watch(visitasViewModelProvider),
    escaneos: ref.watch(pasaporteViewModelProvider).escaneos,
  ),
);
