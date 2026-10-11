import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/almacen/almacen_local.dart';
import '../../../core/almacen/coleccion_local.dart';
import '../domain/cupon.dart';

/// Cupones guardados en el celular (funciona sin señal).
class CuponesRepositoryLocal implements CuponesRepository {
  CuponesRepositoryLocal(this._almacen)
    : _cupones = ColeccionLocal(
        _almacen,
        'turista.cupones',
        aJson: (c) => {
          'id': c.id,
          'productoId': c.productoId,
          'nombreProducto': c.nombreProducto,
          'porcentaje': c.porcentajeDescuento,
          'emitido': fechaAJson(c.emitido),
        },
        deJson: (j) => Cupon(
          id: j['id']! as String,
          productoId: j['productoId']! as String,
          nombreProducto: j['nombreProducto']! as String,
          porcentajeDescuento: j['porcentaje']! as int,
          emitido: fechaDeJson(j['emitido']),
        ),
      );

  static const _claveUsados = 'puesto.cuponesUsados';

  final AlmacenLocal _almacen;
  final ColeccionLocal<Cupon> _cupones;

  @override
  List<Cupon> cupones() => _cupones.leer() ?? [];

  @override
  Future<void> guardarCupones(List<Cupon> cupones) => _cupones.guardar(cupones);

  @override
  Set<String> usados() {
    final texto = _almacen.leer(_claveUsados);
    if (texto == null) return {};
    try {
      return {for (final id in jsonDecode(texto) as List<Object?>) '$id'};
    } on FormatException {
      return {};
    }
  }

  @override
  Future<void> guardarUsados(Set<String> ids) =>
      _almacen.guardar(_claveUsados, jsonEncode(ids.toList()));
}

final cuponesRepositoryProvider = Provider<CuponesRepository>(
  (ref) => CuponesRepositoryLocal(ref.watch(almacenLocalProvider)),
);
