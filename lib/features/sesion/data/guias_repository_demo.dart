import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/guia.dart';
import '../domain/guias_repository.dart';

/// Guías de demostración. Se reemplazan por los que la asociación registre
/// en el portal web cuando exista su tabla en Supabase.
class GuiasRepositoryDemo implements GuiasRepository {
  const GuiasRepositoryDemo();

  static const _nombres = [
    'María Quispe',
    'Juan Chunga',
    'Rosa Yarlequé',
    'Pedro Ancajima',
  ];

  @override
  List<Guia> guiasDe(String asociacionId) => [
    for (final (indice, nombre) in _nombres.indexed)
      Guia(id: 'g${indice + 1}', asociacionId: asociacionId, nombre: nombre),
  ]..sort((a, b) => a.nombre.compareTo(b.nombre));
}

final guiasRepositoryProvider = Provider<GuiasRepository>(
  (ref) => const GuiasRepositoryDemo(),
);
