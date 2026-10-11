import 'package:explorador_bosque_seco/features/conexion/data/conexion_repository_supabase.dart';
import 'package:explorador_bosque_seco/features/conexion/domain/estado_conexion.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Respuesta JSON como la que devuelve PostgREST.
http.Response respuesta(String cuerpo, int estado) => http.Response(
  cuerpo,
  estado,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  /// Repositorio conectado a un servidor simulado (sin red).
  ConexionRepositorySupabase conServidor(
    Future<http.Response> Function(http.Request pedido) responder, {
    Duration tiempoMaximo = const Duration(seconds: 5),
  }) {
    final cliente = SupabaseClient(
      'https://ejemplo.supabase.co',
      'sb_publishable_prueba',
      // Como en un servidor real, cada respuesta lleva el pedido que la
      // originó (postgrest lo usa para interpretar los errores).
      httpClient: MockClient((pedido) async {
        final simulada = await responder(pedido);
        return http.Response(
          simulada.body,
          simulada.statusCode,
          headers: simulada.headers,
          request: pedido,
        );
      }),
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    addTearDown(cliente.dispose);
    return ConexionRepositorySupabase(cliente, tiempoMaximo: tiempoMaximo);
  }

  test(
    'pide una sola fila de la tabla del catálogo con la clave pública',
    () async {
      late http.Request pedido;
      final repositorio = conServidor((recibido) async {
        pedido = recibido;
        return respuesta('[]', 200);
      });

      await repositorio.verificar();

      expect(pedido.url.path, '/rest/v1/espacios');
      expect(pedido.url.queryParameters, containsPair('limit', '1'));
      expect(pedido.headers['apikey'], 'sb_publishable_prueba');
    },
  );

  test(
    'si el servidor responde y la tabla existe, está conectado y listo',
    () async {
      final repositorio = conServidor((_) async => respuesta('[]', 200));

      final estado = await repositorio.verificar();

      expect(
        estado,
        isA<Conectado>().having((c) => c.esquemaListo, 'esquemaListo', isTrue),
      );
    },
  );

  test(
    'si la tabla aún no existe, está conectado pero falta el esquema',
    () async {
      final repositorio = conServidor(
        (_) async => respuesta(
          '{"code":"PGRST205","details":null,"hint":null,'
          '"message":"Could not find the table \'public.espacios\'"}',
          404,
        ),
      );

      final estado = await repositorio.verificar();

      expect(
        estado,
        isA<Conectado>().having((c) => c.esquemaListo, 'esquemaListo', isFalse),
      );
    },
  );

  test('si el servidor rechaza la clave, lo informa', () async {
    final repositorio = conServidor(
      (_) async => respuesta(
        '{"message":"Invalid API key","hint":"Double check your API key."}',
        401,
      ),
    );

    expect(await repositorio.verificar(), isA<ClaveRechazada>());
  });

  test(
    'sin internet informa que no hay conexión, sin lanzar errores',
    () async {
      final repositorio = conServidor(
        (_) async => throw http.ClientException('Failed host lookup'),
      );

      expect(await repositorio.verificar(), isA<SinConexion>());
    },
  );

  test('si el servidor tarda demasiado, informa que no hay conexión', () async {
    final repositorio = conServidor((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return respuesta('[]', 200);
    }, tiempoMaximo: const Duration(milliseconds: 20));

    expect(await repositorio.verificar(), isA<SinConexion>());
  });

  test('otros errores del servidor se informan con su código', () async {
    final repositorio = conServidor(
      (_) async => respuesta('{"message":"Internal error"}', 500),
    );

    expect(
      await repositorio.verificar(),
      isA<ErrorServidor>().having((e) => e.codigo, 'codigo', '500'),
    );
  });
}
