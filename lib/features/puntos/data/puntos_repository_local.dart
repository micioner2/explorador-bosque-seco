import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/almacen/almacen_local.dart';
import '../../../core/almacen/coleccion_local.dart';
import '../domain/escaneo.dart';
import '../domain/pasaporte.dart';
import '../domain/producto.dart';
import '../domain/puntos_repository.dart';
import 'puntos_repository_demo.dart';

/// Pasaporte guardado en el celular del turista: los sellos sobreviven al
/// cerrar la app y se ganan en modo avión.
class PuntosRepositoryLocal implements PuntosRepository {
  PuntosRepositoryLocal(this._almacen, {this.semilla});

  static const _clave = 'turista.pasaporte';

  final AlmacenLocal _almacen;

  /// Pasaporte con el que empieza el celular la primera vez (datos de
  /// demostración), o `null` para empezar vacío.
  final Pasaporte Function()? semilla;

  @override
  Pasaporte pasaporte() {
    final texto = _almacen.leer(_clave);
    if (texto != null) {
      try {
        return pasaporteDeJson(jsonDecode(texto) as Map<String, Object?>);
      } on Object catch (error) {
        debugPrint('No se pudo leer el pasaporte: $error');
      }
    }
    final inicial = semilla?.call() ?? Pasaporte();
    guardar(inicial);
    return inicial;
  }

  @override
  Future<void> guardar(Pasaporte pasaporte) =>
      _almacen.guardar(_clave, jsonEncode(pasaporteAJson(pasaporte)));

  /// El catálogo de productos aún es el de demostración.
  @override
  List<Producto> productos() => const PuntosRepositoryDemo().productos();
}

Map<String, Object?> pasaporteAJson(Pasaporte pasaporte) => {
  'puntosCanjeados': pasaporte.puntosCanjeados,
  'escaneos': [
    for (final escaneo in pasaporte.escaneos)
      {
        'id': escaneo.id,
        'visitaId': escaneo.visitaId,
        'puntoId': escaneo.puntoId,
        'fecha': fechaAJson(escaneo.fecha),
        'estado': escaneo.estado.name,
      },
  ],
};

Pasaporte pasaporteDeJson(Map<String, Object?> json) => Pasaporte(
  puntosCanjeados: json['puntosCanjeados']! as int,
  escaneos: [
    for (final escaneo in json['escaneos']! as List<Object?>)
      _escaneoDeJson(escaneo! as Map<String, Object?>),
  ],
);

Escaneo _escaneoDeJson(Map<String, Object?> json) => Escaneo(
  id: json['id']! as String,
  visitaId: json['visitaId']! as String,
  puntoId: json['puntoId']! as String,
  fecha: fechaDeJson(json['fecha']),
  estado: EstadoEscaneo.values.byName(json['estado']! as String),
);

/// Punto único donde se elige la implementación: el pasaporte vive en el
/// celular. Sin servidor (cuenta de prueba), empieza con el de
/// demostración.
final puntosRepositoryProvider = Provider<PuntosRepository>(
  (ref) => PuntosRepositoryLocal(
    ref.watch(almacenLocalProvider),
    semilla: ref.watch(datosDemoProvider)
        ? const PuntosRepositoryDemo().pasaporte
        : null,
  ),
);
