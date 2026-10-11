import 'package:shared_preferences/shared_preferences.dart';

import '../../mapa/domain/coordenada.dart';
import '../domain/preferencias.dart';
import '../domain/preferencias_repository.dart';

/// Guarda las preferencias en el celular para que el idioma y el tema
/// elegidos se mantengan al volver a abrir la app (también sin señal).
class PreferenciasRepositoryLocal implements PreferenciasRepository {
  const PreferenciasRepositoryLocal(this._almacen);

  static const _claveIdioma = 'preferencias.idioma';
  static const _claveTema = 'preferencias.tema';
  static const _claveRuta = 'preferencias.rutaDemo';
  static const _claveCentro = 'preferencias.centroSede';

  final SharedPreferences _almacen;

  @override
  Preferencias leer() => Preferencias(
    idioma: Idioma.deCodigo(_almacen.getString(_claveIdioma)),
    modoTema: ModoTema.deNombre(_almacen.getString(_claveTema)),
    rutaDemo: RutaDemo.deNombre(_almacen.getString(_claveRuta)),
    centroSede: _centro(_almacen.getString(_claveCentro)),
  );

  /// "lat,lon" → coordenada; `null` si no hay o está dañado.
  static Coordenada? _centro(String? texto) {
    final partes = texto?.split(',');
    if (partes == null || partes.length != 2) return null;
    final lat = double.tryParse(partes[0]);
    final lon = double.tryParse(partes[1]);
    return (lat == null || lon == null) ? null : Coordenada(lat, lon);
  }

  @override
  Future<void> guardar(Preferencias preferencias) async {
    final idioma = preferencias.idioma;
    if (idioma == null) {
      await _almacen.remove(_claveIdioma);
    } else {
      await _almacen.setString(_claveIdioma, idioma.codigo);
    }
    await _almacen.setString(_claveTema, preferencias.modoTema.name);
    await _almacen.setString(_claveRuta, preferencias.rutaDemo.name);
    final centro = preferencias.centroSede;
    if (centro != null) {
      await _almacen.setString(
        _claveCentro,
        '${centro.latitud},${centro.longitud}',
      );
    }
  }
}
