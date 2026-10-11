import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/red_repository.dart';

/// Red del celular con `connectivity_plus`. Mira si hay wifi o datos, no
/// si el servidor responde: eso lo dice la sincronización.
class RedRepositoryConectividad implements RedRepository {
  RedRepositoryConectividad([Connectivity? conectividad])
    : _conectividad = conectividad ?? Connectivity();

  final Connectivity _conectividad;

  static bool _conRed(List<ConnectivityResult> resultados) =>
      resultados.any((r) => r != ConnectivityResult.none);

  @override
  Stream<bool> hayRed() async* {
    yield _conRed(await _conectividad.checkConnectivity());
    yield* _conectividad.onConnectivityChanged.map(_conRed);
  }
}

final redRepositoryProvider = Provider<RedRepository>(
  (ref) => RedRepositoryConectividad(),
);
