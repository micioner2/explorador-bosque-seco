import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/sesion_repository_demo.dart';
import '../../domain/resultado_acceso.dart';
import 'sesion_view_model.dart';

/// Lo que muestra la pantalla de acceso.
class EstadoAcceso {
  const EstadoAcceso({this.entrando = false, this.rechazo, this.cuentaDemo});

  /// Se está verificando la cuenta con el servidor.
  final bool entrando;

  /// Por qué no se pudo entrar en el último intento, si falló.
  final AccesoDenegado? rechazo;

  /// Correo y contraseña de prueba. Solo existe cuando la app se compiló
  /// sin servidor, para poder mostrarla en una demostración.
  final ({String correo, String clave})? cuentaDemo;
}

/// Estado y acciones de la pantalla de acceso de la asociación.
class AccesoViewModel extends Notifier<EstadoAcceso> {
  @override
  EstadoAcceso build() => EstadoAcceso(
    cuentaDemo: ref.watch(sesionRepositoryProvider) is SesionRepositoryDemo
        ? (
            correo: SesionRepositoryDemo.correoDemo,
            clave: SesionRepositoryDemo.claveDemo,
          )
        : null,
  );

  /// Verifica la cuenta. Si es válida, abre la sesión y devuelve `true`;
  /// si no, deja el motivo en [EstadoAcceso.rechazo].
  Future<bool> entrar({required String correo, required String clave}) async {
    if (state.entrando) return false;
    final cuentaDemo = state.cuentaDemo;
    state = EstadoAcceso(entrando: true, cuentaDemo: cuentaDemo);

    final resultado = await ref
        .read(sesionRepositoryProvider)
        .iniciarSesion(correo: correo, clave: clave);
    if (!ref.mounted) return false;

    switch (resultado) {
      case AccesoConcedido(:final cuenta):
        state = EstadoAcceso(cuentaDemo: cuentaDemo);
        ref.read(sesionViewModelProvider.notifier).abrir(cuenta);
        return true;
      case AccesoDenegado():
        state = EstadoAcceso(rechazo: resultado, cuentaDemo: cuentaDemo);
        return false;
    }
  }
}

final accesoViewModelProvider =
    NotifierProvider.autoDispose<AccesoViewModel, EstadoAcceso>(
      AccesoViewModel.new,
    );
