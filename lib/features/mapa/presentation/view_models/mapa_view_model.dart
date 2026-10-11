import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../puntos/presentation/view_models/pasaporte_view_model.dart';
import '../../data/ruta_repository_demo.dart';
import '../../domain/progreso_ruta.dart';

/// Estado de la pantalla Mapa: la ruta y el avance del turista en ella.
/// Se recalcula cada vez que el pasaporte gana o confirma un sello.
final mapaViewModelProvider = Provider<ProgresoRuta>(
  (ref) => ProgresoRuta.calcular(
    ref.watch(rutaRepositoryProvider).rutaActual(),
    ref.watch(pasaporteViewModelProvider).sellos,
  ),
);
