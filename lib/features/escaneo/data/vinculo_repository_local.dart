import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/almacen/almacen_local.dart';
import '../domain/vinculo_repository.dart';

/// Guarda el vínculo con el grupo en el almacén del celular.
class VinculoRepositoryLocal implements VinculoRepository {
  const VinculoRepositoryLocal(this._almacen);

  static const _clave = 'turista.visitaVinculada';

  final AlmacenLocal _almacen;

  @override
  String? visitaVinculada() => _almacen.leer(_clave);

  @override
  Future<void> vincular(String visitaId) => _almacen.guardar(_clave, visitaId);
}

final vinculoRepositoryProvider = Provider<VinculoRepository>(
  (ref) => VinculoRepositoryLocal(ref.watch(almacenLocalProvider)),
);
