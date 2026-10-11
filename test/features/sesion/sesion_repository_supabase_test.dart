import 'dart:convert';

import 'package:explorador_bosque_seco/features/sesion/data/sesion_repository_supabase.dart';
import 'package:explorador_bosque_seco/features/sesion/domain/cuenta_asociacion.dart';
import 'package:explorador_bosque_seco/features/sesion/domain/resultado_acceso.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Respuesta JSON como las de Supabase (Auth y PostgREST).
http.Response respuesta(Object cuerpo, int estado) => http.Response(
  jsonEncode(cuerpo),
  estado,
  headers: {
    'content-type': 'application/json; charset=utf-8',
    'x-supabase-api-version': '2024-01-01',
  },
);

/// Token con forma de JWT válido hasta el año 2100 (la firma no se revisa
/// en el celular).
String _jwt() {
  String parte(Object datos) =>
      base64Url.encode(utf8.encode(jsonEncode(datos))).replaceAll('=', '');
  final carga = {'sub': 'u1', 'role': 'authenticated', 'exp': 4102444800};
  return '${parte({'alg': 'HS256', 'typ': 'JWT'})}.${parte(carga)}.firma';
}

/// Lo que responde Supabase Auth al entrar con correo y contraseña.
Map<String, Object> _sesion() => {
  'access_token': _jwt(),
  'token_type': 'bearer',
  'expires_in': 3600,
  'expires_at': 4102444800,
  'refresh_token': 'renovar-1',
  'user': {
    'id': 'u1',
    'aud': 'authenticated',
    'role': 'authenticated',
    'email': 'lancones@ejemplo.pe',
    'app_metadata': <String, Object>{},
    'user_metadata': <String, Object>{},
    'created_at': '2026-10-01T00:00:00Z',
  },
};

/// Servidor simulado: responde según la ruta y guarda los pedidos.
class _Servidor {
  final pedidos = <http.Request>[];

  /// Si es `true`, el servidor deja de estar al alcance (sin señal).
  bool sinSenal = false;

  http.Response Function() acceso = () => respuesta(_sesion(), 200);
  Object perfiles = [
    {'association_id': 'a-lancones'},
  ];
  Object asociaciones = [
    {'name': 'Bosques de Lancones', 'is_active': true},
  ];

  Future<http.Response> responder(http.Request pedido) async {
    if (sinSenal) throw http.ClientException('Failed host lookup');
    pedidos.add(pedido);
    final simulada = switch (pedido.url.path) {
      '/auth/v1/token' => acceso(),
      '/auth/v1/logout' => http.Response('', 204),
      '/rest/v1/profiles' => respuesta(perfiles, 200),
      '/rest/v1/associations' => respuesta(asociaciones, 200),
      _ => respuesta({'message': 'no existe'}, 404),
    };
    // Como en un servidor real, cada respuesta lleva el pedido que la
    // originó (postgrest lo usa para interpretar los errores).
    return http.Response(
      simulada.body,
      simulada.statusCode,
      headers: simulada.headers,
      request: pedido,
    );
  }
}

void main() {
  late _Servidor servidor;
  late SupabaseClient cliente;
  late SharedPreferences almacen;
  late SesionRepositorySupabase repositorio;

  setUp(() async {
    servidor = _Servidor();
    cliente = SupabaseClient(
      'https://ejemplo.supabase.co',
      'sb_publishable_prueba',
      httpClient: MockClient(servidor.responder),
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    addTearDown(cliente.dispose);
    SharedPreferences.setMockInitialValues({});
    almacen = await SharedPreferences.getInstance();
    repositorio = SesionRepositorySupabase(cliente, almacen);
  });

  Future<ResultadoAcceso> entrar() =>
      repositorio.iniciarSesion(correo: ' lancones@ejemplo.pe ', clave: 'x');

  Matcher denegadoPor(MotivoRechazo motivo) =>
      isA<AccesoDenegado>().having((r) => r.motivo, 'motivo', motivo);

  const cuentaLancones = CuentaAsociacion(
    asociacionId: 'a-lancones',
    nombreAsociacion: 'Bosques de Lancones',
    correo: 'lancones@ejemplo.pe',
  );

  test(
    'entra con correo y contraseña y lee la asociación de la cuenta',
    () async {
      final resultado = await entrar();

      expect(
        resultado,
        isA<AccesoConcedido>().having(
          (r) => r.cuenta,
          'cuenta',
          cuentaLancones,
        ),
      );
      final acceso = servidor.pedidos.first;
      expect(acceso.url.queryParameters['grant_type'], 'password');
      expect(
        jsonDecode(acceso.body),
        containsPair('email', 'lancones@ejemplo.pe'),
      );
      final perfil = servidor.pedidos[1];
      expect(perfil.url.path, '/rest/v1/profiles');
      expect(perfil.url.queryParameters['id'], 'eq.u1');
    },
  );

  test('después de entrar, la cuenta se recupera sin señal', () async {
    await entrar();
    servidor.sinSenal = true;

    final alReabrir = SesionRepositorySupabase(cliente, almacen);

    expect(alReabrir.cuentaGuardada(), cuentaLancones);
  });

  test('sin la sesión de Supabase hay que volver a entrar, aunque queden '
      'los datos de la asociación', () async {
    await entrar();
    final otroCliente = SupabaseClient(
      'https://ejemplo.supabase.co',
      'sb_publishable_prueba',
      httpClient: MockClient(servidor.responder),
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    addTearDown(otroCliente.dispose);

    expect(
      SesionRepositorySupabase(otroCliente, almacen).cuentaGuardada(),
      isNull,
    );
  });

  test('con correo o contraseña equivocados lo dice', () async {
    servidor.acceso = () => respuesta({
      'code': 'invalid_credentials',
      'message': 'Invalid login credentials',
    }, 400);

    expect(await entrar(), denegadoPor(MotivoRechazo.credencialesIncorrectas));
    expect(repositorio.cuentaGuardada(), isNull);
  });

  test(
    'sin señal informa que hace falta conexión, sin lanzar errores',
    () async {
      servidor.sinSenal = true;

      expect(await entrar(), denegadoPor(MotivoRechazo.sinConexion));
    },
  );

  test('si el servidor tarda demasiado, informa que no hay conexión', () async {
    final clienteLento = SupabaseClient(
      'https://ejemplo.supabase.co',
      'sb_publishable_prueba',
      httpClient: MockClient((pedido) async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        return servidor.responder(pedido);
      }),
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    addTearDown(clienteLento.dispose);
    final lento = SesionRepositorySupabase(
      clienteLento,
      almacen,
      tiempoMaximo: const Duration(milliseconds: 20),
    );

    expect(
      await lento.iniciarSesion(correo: 'a@b.pe', clave: 'x'),
      denegadoPor(MotivoRechazo.sinConexion),
    );
  });

  test('una cuenta sin asociación no queda abierta', () async {
    servidor.perfiles = [
      {'association_id': null},
    ];

    expect(await entrar(), denegadoPor(MotivoRechazo.cuentaNoHabilitada));
    expect(cliente.auth.currentSession, isNull);
    expect(repositorio.cuentaGuardada(), isNull);
  });

  test('si la cuenta no puede leer su perfil, no está habilitada', () async {
    servidor.perfiles = <Object>[];

    expect(await entrar(), denegadoPor(MotivoRechazo.cuentaNoHabilitada));
  });

  test('una asociación desactivada no puede entrar', () async {
    servidor.asociaciones = [
      {'name': 'Bosques de Lancones', 'is_active': false},
    ];

    expect(await entrar(), denegadoPor(MotivoRechazo.cuentaNoHabilitada));
  });

  test('si hubo demasiados intentos, pide esperar', () async {
    servidor.acceso = () => respuesta({
      'code': 'over_request_rate_limit',
      'message': 'Request rate limit reached',
    }, 429);

    expect(await entrar(), denegadoPor(MotivoRechazo.demasiadosIntentos));
  });

  test('un error del servidor se informa con su código', () async {
    servidor.acceso = () => respuesta({'message': 'Internal error'}, 500);

    expect(
      await entrar(),
      isA<AccesoDenegado>()
          .having((r) => r.motivo, 'motivo', MotivoRechazo.errorDelServidor)
          .having((r) => r.codigo, 'codigo', '500'),
    );
  });

  test('salir de la cuenta funciona sin señal', () async {
    await entrar();
    servidor.sinSenal = true;

    await repositorio.cerrarSesion();

    expect(cliente.auth.currentSession, isNull);
    expect(repositorio.cuentaGuardada(), isNull);
    expect(almacen.getKeys(), isEmpty);
  });
}
