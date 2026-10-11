import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/almacen/almacen_local.dart';
import '../domain/guia.dart';
import '../domain/ultimo_guia_repository.dart';

/// Guarda el último guía en el almacén del celular, uno por asociación.
class UltimoGuiaRepositoryLocal implements UltimoGuiaRepository {
  const UltimoGuiaRepositoryLocal(this._almacen);

  final AlmacenLocal _almacen;

  static String _clave(String asociacionId) =>
      'sesion.ultimoGuia.$asociacionId';

  @override
  String? ultimoGuiaId(String asociacionId) =>
      _almacen.leer(_clave(asociacionId));

  @override
  Future<void> recordar(Guia guia) =>
      _almacen.guardar(_clave(guia.asociacionId), guia.id);
}

final ultimoGuiaRepositoryProvider = Provider<UltimoGuiaRepository>(
  (ref) => UltimoGuiaRepositoryLocal(ref.watch(almacenLocalProvider)),
);
