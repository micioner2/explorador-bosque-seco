import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/cuenta_asociacion.dart';
import '../domain/resultado_acceso.dart';
import '../domain/sesion_repository.dart';

/// Acceso de demostración, para cuando la app se compila sin servidor.
/// Acepta solo la cuenta de prueba, que la pantalla de acceso muestra.
class SesionRepositoryDemo implements SesionRepository {
  SesionRepositoryDemo({CuentaAsociacion? cuentaGuardada})
    : _cuenta = cuentaGuardada;

  static const correoDemo = 'demo@bosqueseco.pe';
  static const claveDemo = 'bosque2026';

  static const cuentaDemo = CuentaAsociacion(
    asociacionId: 'demo',
    nombreAsociacion: 'Coto de Caza El Angolo',
    correo: correoDemo,
  );

  CuentaAsociacion? _cuenta;

  @override
  CuentaAsociacion? cuentaGuardada() => _cuenta;

  @override
  Future<ResultadoAcceso> iniciarSesion({
    required String correo,
    required String clave,
  }) async {
    if (correo.trim().toLowerCase() != correoDemo || clave != claveDemo) {
      return const AccesoDenegado(MotivoRechazo.credencialesIncorrectas);
    }
    _cuenta = cuentaDemo;
    return const AccesoConcedido(cuentaDemo);
  }

  @override
  Future<void> cerrarSesion() async {
    _cuenta = null;
  }
}

/// Punto único donde se elige la implementación del repositorio.
///
/// `main.dart` lo sustituye por `SesionRepositorySupabase` cuando la app se
/// compila con servidor.
final sesionRepositoryProvider = Provider<SesionRepository>(
  (ref) => SesionRepositoryDemo(),
);
