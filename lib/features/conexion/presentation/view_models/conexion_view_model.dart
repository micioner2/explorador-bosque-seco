import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/conexion_repository_supabase.dart';
import '../../domain/estado_conexion.dart';

/// Estado y acciones de la prueba de conexión con el servidor.
///
/// Prueba la conexión al abrir la pantalla que la muestra y se descarta al
/// cerrarla, así cada visita a Ajustes muestra el estado actual.
class ConexionViewModel extends AsyncNotifier<EstadoConexion> {
  @override
  Future<EstadoConexion> build() =>
      ref.watch(conexionRepositoryProvider).verificar();

  Future<void> probarDeNuevo() async {
    state = const AsyncLoading();
    final estado = await ref.read(conexionRepositoryProvider).verificar();
    if (ref.mounted) state = AsyncData(estado);
  }
}

final conexionViewModelProvider =
    AsyncNotifierProvider.autoDispose<ConexionViewModel, EstadoConexion>(
      ConexionViewModel.new,
    );
