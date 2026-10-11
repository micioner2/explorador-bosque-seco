import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/guias_repository_demo.dart';
import '../../data/sesion_repository_demo.dart';
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

  void elegirGuia(Guia guia) => state = state.elegirGuia(guia);

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
