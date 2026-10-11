import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/guias_repository_demo.dart';
import '../../data/sesion_repository_demo.dart';
import '../../data/ultimo_guia_repository_local.dart';
import '../../domain/cuenta_asociacion.dart';
import '../../domain/guia.dart';
import '../../domain/sesion.dart';

/// Estado y acciones de la sesión del puesto de control: la cuenta de la
/// asociación y el guía que está registrando.
class SesionViewModel extends Notifier<Sesion> {
  @override
  Sesion build() =>
      Sesion(cuenta: ref.watch(sesionRepositoryProvider).cuentaGuardada());

  /// La asociación entró con su cuenta: falta que el guía elija su nombre.
  void abrir(CuentaAsociacion cuenta) => state = Sesion(cuenta: cuenta);

  /// El guía toca su nombre. Queda recordado para que la próxima vez solo
  /// toque "Continuar como…".
  void elegirGuia(Guia guia) {
    final sesion = state.elegirGuia(guia);
    // Se recuerda antes de cambiar la sesión: el último guía se recalcula
    // con ella.
    ref.read(ultimoGuiaRepositoryProvider).recordar(guia);
    state = sesion;
  }

  /// Otro guía toma el celular: la cuenta sigue abierta.
  void cambiarGuia() => state = state.soltarGuia();

  /// Sale de la cuenta en este celular. Para volver a entrar hace falta
  /// señal.
  Future<void> cerrarSesion() async {
    state = const Sesion();
    await ref.read(sesionRepositoryProvider).cerrarSesion();
  }
}

final sesionViewModelProvider = NotifierProvider<SesionViewModel, Sesion>(
  SesionViewModel.new,
);

/// Guías que pueden elegir su nombre con la cuenta abierta.
final guiasDeLaCuentaProvider = Provider<List<Guia>>((ref) {
  final cuenta = ref.watch(sesionViewModelProvider.select((s) => s.cuenta));
  if (cuenta == null) return const [];
  return ref.watch(guiasRepositoryProvider).guiasDe(cuenta.asociacionId);
});

/// Último guía de la asociación que usó este celular, si sigue en la lista
/// de guías. La pantalla "¿Quién eres?" le ofrece continuar con un toque.
/// Se recalcula cada vez que alguien elige su nombre.
final ultimoGuiaViewModelProvider = Provider<Guia?>((ref) {
  final (cuenta, _) = ref.watch(
    sesionViewModelProvider.select((s) => (s.cuenta, s.guia)),
  );
  if (cuenta == null) return null;
  final id = ref
      .watch(ultimoGuiaRepositoryProvider)
      .ultimoGuiaId(cuenta.asociacionId);
  if (id == null) return null;
  return ref
      .watch(guiasDeLaCuentaProvider)
      .where((guia) => guia.id == id)
      .firstOrNull;
});
