import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/preferencias.dart';
import '../domain/preferencias_repository.dart';

/// Preferencias que solo viven mientras la app está abierta. Se usa en las
/// pruebas y como respaldo si no se pudo abrir el almacenamiento del celular.
class PreferenciasRepositoryMemoria implements PreferenciasRepository {
  PreferenciasRepositoryMemoria([this._preferencias = const Preferencias()]);

  Preferencias _preferencias;

  @override
  Preferencias leer() => _preferencias;

  @override
  Future<void> guardar(Preferencias preferencias) async {
    _preferencias = preferencias;
  }
}

/// Punto único donde se elige la implementación del repositorio.
///
/// El almacenamiento del celular se abre de forma asíncrona, así que
/// `main.dart` lo sustituye por `PreferenciasRepositoryLocal` al arrancar.
final preferenciasRepositoryProvider = Provider<PreferenciasRepository>(
  (ref) => PreferenciasRepositoryMemoria(),
);
