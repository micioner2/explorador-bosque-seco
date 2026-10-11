import 'package:shared_preferences/shared_preferences.dart';

import '../domain/preferencias.dart';
import '../domain/preferencias_repository.dart';

/// Guarda las preferencias en el celular para que el idioma y el tema
/// elegidos se mantengan al volver a abrir la app (también sin señal).
class PreferenciasRepositoryLocal implements PreferenciasRepository {
  const PreferenciasRepositoryLocal(this._almacen);

  static const _claveIdioma = 'preferencias.idioma';
  static const _claveTema = 'preferencias.tema';

  final SharedPreferences _almacen;

  @override
  Preferencias leer() => Preferencias(
    idioma: Idioma.deCodigo(_almacen.getString(_claveIdioma)),
    modoTema: ModoTema.deNombre(_almacen.getString(_claveTema)),
  );

  @override
  Future<void> guardar(Preferencias preferencias) async {
    final idioma = preferencias.idioma;
    if (idioma == null) {
      await _almacen.remove(_claveIdioma);
    } else {
      await _almacen.setString(_claveIdioma, idioma.codigo);
    }
    await _almacen.setString(_claveTema, preferencias.modoTema.name);
  }
}
