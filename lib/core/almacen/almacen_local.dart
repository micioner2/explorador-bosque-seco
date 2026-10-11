import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Almacén de textos del celular (clave → valor) para los repositorios de
/// la capa `data`. Es la fuente de verdad offline: lo que se guarda aquí
/// sobrevive al cerrar la app y no necesita señal.
///
/// Lectura síncrona (se abre una vez al arrancar) y escritura asíncrona.
abstract interface class AlmacenLocal {
  String? leer(String clave);

  Future<void> guardar(String clave, String valor);

  Future<void> borrar(String clave);
}

/// Almacén que solo vive mientras la app está abierta. Es el que usan las
/// pruebas y el respaldo si no se pudo abrir el almacenamiento del celular.
class AlmacenMemoria implements AlmacenLocal {
  AlmacenMemoria([Map<String, String>? inicial]) : _datos = {...?inicial};

  final Map<String, String> _datos;

  @override
  String? leer(String clave) => _datos[clave];

  @override
  Future<void> guardar(String clave, String valor) async {
    _datos[clave] = valor;
  }

  @override
  Future<void> borrar(String clave) async {
    _datos.remove(clave);
  }
}

/// Almacén del celular con `shared_preferences`.
class AlmacenPreferencias implements AlmacenLocal {
  const AlmacenPreferencias(this._preferencias);

  final SharedPreferences _preferencias;

  @override
  String? leer(String clave) => _preferencias.getString(clave);

  @override
  Future<void> guardar(String clave, String valor) =>
      _preferencias.setString(clave, valor);

  @override
  Future<void> borrar(String clave) => _preferencias.remove(clave);
}

/// Punto único donde se elige el almacén. `main.dart` lo sustituye por
/// [AlmacenPreferencias] al arrancar.
final almacenLocalProvider = Provider<AlmacenLocal>((ref) => AlmacenMemoria());
