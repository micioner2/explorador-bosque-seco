import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'almacen_local.dart';

/// Lista de registros guardada como JSON en el [AlmacenLocal], para los
/// repositorios offline. Cada registro se guarda completo, con su id
/// generado en el celular.
class ColeccionLocal<T> {
  const ColeccionLocal(
    this._almacen,
    this.clave, {
    required this.aJson,
    required this.deJson,
  });

  final AlmacenLocal _almacen;
  final String clave;
  final Map<String, Object?> Function(T registro) aJson;
  final T Function(Map<String, Object?> json) deJson;

  /// Registros guardados, o `null` si esta colección nunca se guardó en
  /// este celular. Si lo guardado está dañado, también devuelve `null`.
  List<T>? leer() {
    final texto = _almacen.leer(clave);
    if (texto == null) return null;
    try {
      final lista = jsonDecode(texto) as List<Object?>;
      return [for (final json in lista) deJson(json! as Map<String, Object?>)];
    } on Object catch (error) {
      debugPrint('No se pudo leer $clave: $error');
      return null;
    }
  }

  Future<void> guardar(Iterable<T> registros) => _almacen.guardar(
    clave,
    jsonEncode([for (final registro in registros) aJson(registro)]),
  );
}

/// Si los repositorios empiezan con los datos de demostración la primera
/// vez que se abre la app. `main.dart` lo apaga cuando la app se compila
/// con Supabase: con cuentas reales, el celular empieza vacío.
final datosDemoProvider = Provider<bool>((ref) => true);

/// Fechas en JSON: texto ISO 8601 en hora local.
String fechaAJson(DateTime fecha) => fecha.toIso8601String();

DateTime fechaDeJson(Object? json) => DateTime.parse(json! as String);

DateTime? fechaODeJson(Object? json) =>
    json == null ? null : DateTime.parse(json as String);
