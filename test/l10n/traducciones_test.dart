import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Lee un archivo de traducciones y devuelve solo los textos (sin los
/// metadatos que empiezan con @).
Map<String, String> leerTextos(String idioma) {
  final contenido = File('lib/l10n/app_$idioma.arb').readAsStringSync();
  final json = jsonDecode(contenido) as Map<String, dynamic>;
  return {
    for (final MapEntry(:key, :value) in json.entries)
      if (!key.startsWith('@')) key: value as String,
  };
}

/// Nombres de las variables de un texto: `{nombre}` o `{n, plural, ...}`.
/// No cuenta las opciones de un plural (`=1{punto} other{puntos}`), que son
/// texto y sí cambian entre idiomas.
Set<String> variables(String texto) => {
  for (final coincidencia in RegExp(
    r'(?<!(?:=\d+|zero|one|two|few|many|other))\{(\w+)\s*[,}]',
  ).allMatches(texto))
    coincidencia.group(1)!,
};

void main() {
  final espanol = leerTextos('es');
  final ingles = leerTextos('en');

  test('español e inglés tienen exactamente los mismos textos', () {
    expect(
      ingles.keys.toSet().difference(espanol.keys.toSet()),
      isEmpty,
      reason: 'Sobran en app_en.arb',
    );
    expect(
      espanol.keys.toSet().difference(ingles.keys.toSet()),
      isEmpty,
      reason: 'Faltan traducir en app_en.arb',
    );
  });

  test('ningún texto quedó vacío', () {
    for (final textos in [espanol, ingles]) {
      for (final MapEntry(key: clave, value: texto) in textos.entries) {
        expect(texto.trim(), isNotEmpty, reason: clave);
      }
    }
  });

  test('cada traducción usa las mismas variables que el original', () {
    for (final MapEntry(key: clave, value: texto) in espanol.entries) {
      expect(variables(ingles[clave] ?? ''), variables(texto), reason: clave);
    }
  });
}
