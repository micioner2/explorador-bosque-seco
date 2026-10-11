import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/cuenta_asociacion.dart';
import '../domain/resultado_acceso.dart';
import '../domain/sesion_repository.dart';

/// Acceso con las cuentas de Supabase Auth que crea el portal web.
///
/// Al entrar (con señal) lee en `profiles` la asociación de la cuenta y en
/// `associations` su nombre, y los guarda en el celular. Después todo se
/// lee sin conectarse: Supabase guarda su propia sesión y la renueva sola
/// cuando vuelve la señal. Solo la cierra si el servidor rechaza la cuenta
/// (por ejemplo, si le cambiaron la contraseña); nunca por falta de señal.
class SesionRepositorySupabase implements SesionRepository {
  const SesionRepositorySupabase(
    this._cliente,
    this._almacen, {
    this.tiempoMaximo = const Duration(seconds: 20),
  });

  static const _claveAsociacionId = 'sesion.asociacionId';
  static const _claveAsociacionNombre = 'sesion.asociacionNombre';
  static const _claveCorreo = 'sesion.correo';

  /// Códigos de Supabase Auth para cada motivo de rechazo.
  static const _credencialesIncorrectas = {
    'invalid_credentials',
    'invalid_grant',
  };
  static const _cuentaNoHabilitada = {
    'email_not_confirmed',
    'user_banned',
    'user_not_found',
  };
  static const _demasiadosIntentos = {
    'over_request_rate_limit',
    'over_email_send_rate_limit',
  };

  final SupabaseClient _cliente;
  final SharedPreferences _almacen;
  final Duration tiempoMaximo;

  @override
  CuentaAsociacion? cuentaGuardada() {
    // Sin la sesión de Supabase (se cerró o el servidor la rechazó) hay que
    // volver a entrar, aunque queden los datos de la asociación.
    if (_cliente.auth.currentSession == null) return null;
    final asociacionId = _almacen.getString(_claveAsociacionId);
    final nombre = _almacen.getString(_claveAsociacionNombre);
    final correo = _almacen.getString(_claveCorreo);
    if (asociacionId == null || nombre == null || correo == null) return null;
    return CuentaAsociacion(
      asociacionId: asociacionId,
      nombreAsociacion: nombre,
      correo: correo,
    );
  }

  @override
  Future<ResultadoAcceso> iniciarSesion({
    required String correo,
    required String clave,
  }) async {
    try {
      return await _iniciar(correo.trim(), clave).timeout(tiempoMaximo);
    } on AuthRetryableFetchException catch (error) {
      // Sin código HTTP, el pedido ni siquiera llegó al servidor.
      final codigo = error.statusCode;
      return codigo == null
          ? const AccesoDenegado(MotivoRechazo.sinConexion)
          : AccesoDenegado(MotivoRechazo.errorDelServidor, codigo: codigo);
    } on AuthApiException catch (error) {
      return _segunCodigo(error);
    } on AuthException catch (error) {
      return AccesoDenegado(
        MotivoRechazo.errorDelServidor,
        codigo: error.code ?? error.statusCode,
      );
    } on PostgrestException catch (error) {
      await _cerrarEnElCelular();
      return AccesoDenegado(MotivoRechazo.errorDelServidor, codigo: error.code);
    } on TimeoutException {
      await _cerrarEnElCelular();
      return const AccesoDenegado(MotivoRechazo.sinConexion);
    } on SocketException {
      await _cerrarEnElCelular();
      return const AccesoDenegado(MotivoRechazo.sinConexion);
    } on http.ClientException {
      await _cerrarEnElCelular();
      return const AccesoDenegado(MotivoRechazo.sinConexion);
    }
  }

  Future<ResultadoAcceso> _iniciar(String correo, String clave) async {
    final respuesta = await _cliente.auth.signInWithPassword(
      email: correo,
      password: clave,
    );
    final usuario = respuesta.user;
    if (usuario == null) {
      return const AccesoDenegado(MotivoRechazo.credencialesIncorrectas);
    }

    final perfiles = await _cliente
        .from('profiles')
        .select('association_id')
        .eq('id', usuario.id)
        .limit(1);
    final asociacionId = perfiles.firstOrNull?['association_id'];
    if (asociacionId is! String) return _noHabilitada();

    final asociaciones = await _cliente
        .from('associations')
        .select('name, is_active')
        .eq('id', asociacionId)
        .limit(1);
    final asociacion = asociaciones.firstOrNull;
    final nombre = asociacion?['name'];
    if (nombre is! String || asociacion?['is_active'] == false) {
      return _noHabilitada();
    }

    final cuenta = CuentaAsociacion(
      asociacionId: asociacionId,
      nombreAsociacion: nombre,
      correo: usuario.email ?? correo,
    );
    await _almacen.setString(_claveAsociacionId, cuenta.asociacionId);
    await _almacen.setString(_claveAsociacionNombre, cuenta.nombreAsociacion);
    await _almacen.setString(_claveCorreo, cuenta.correo);
    return AccesoConcedido(cuenta);
  }

  /// La cuenta existe pero no sirve para el puesto de control: no se deja
  /// la sesión abierta.
  Future<ResultadoAcceso> _noHabilitada() async {
    await _cerrarEnElCelular();
    return const AccesoDenegado(MotivoRechazo.cuentaNoHabilitada);
  }

  ResultadoAcceso _segunCodigo(AuthApiException error) {
    final codigo = error.code;
    final estado = error.statusCode;
    if (_credencialesIncorrectas.contains(codigo) ||
        (codigo == null && estado == '400')) {
      return const AccesoDenegado(MotivoRechazo.credencialesIncorrectas);
    }
    if (_cuentaNoHabilitada.contains(codigo)) {
      return const AccesoDenegado(MotivoRechazo.cuentaNoHabilitada);
    }
    if (_demasiadosIntentos.contains(codigo) || estado == '429') {
      return const AccesoDenegado(MotivoRechazo.demasiadosIntentos);
    }
    return AccesoDenegado(
      MotivoRechazo.errorDelServidor,
      codigo: codigo ?? estado,
    );
  }

  @override
  Future<void> cerrarSesion() async {
    await _almacen.remove(_claveAsociacionId);
    await _almacen.remove(_claveAsociacionNombre);
    await _almacen.remove(_claveCorreo);
    await _cerrarEnElCelular();
  }

  /// Supabase borra la sesión del celular antes de avisar al servidor. Si
  /// no hay señal, el aviso falla y la sesión del servidor vence sola.
  Future<void> _cerrarEnElCelular() async {
    try {
      await _cliente.auth.signOut().timeout(const Duration(seconds: 5));
    } on AuthException {
      // Sin señal: la sesión ya se borró del celular.
    } on TimeoutException {
      // Igual que arriba: el servidor no respondió a tiempo.
    }
  }
}
