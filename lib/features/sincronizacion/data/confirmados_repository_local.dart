import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/almacen/almacen_local.dart';
import '../domain/confirmados_repository.dart';

/// Guarda en el celular los ids que el servidor ya aceptó.
class ConfirmadosRepositoryLocal implements ConfirmadosRepository {
  const ConfirmadosRepositoryLocal(this._almacen);

  final AlmacenLocal _almacen;

  static String _clave(String coleccion) => 'sincronizacion.$coleccion';

  @override
  Set<String> confirmados(String coleccion) {
    final texto = _almacen.leer(_clave(coleccion));
    if (texto == null) return {};
    try {
      return {for (final id in jsonDecode(texto) as List<Object?>) '$id'};
    } on FormatException {
      return {};
    }
  }

  @override
  Future<void> confirmar(String coleccion, Iterable<String> ids) =>
      _almacen.guardar(
        _clave(coleccion),
        jsonEncode({...confirmados(coleccion), ...ids}.toList()),
      );
}

final confirmadosRepositoryProvider = Provider<ConfirmadosRepository>(
  (ref) => ConfirmadosRepositoryLocal(ref.watch(almacenLocalProvider)),
);
