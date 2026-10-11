import 'package:explorador_bosque_seco/core/id.dart';
import 'package:explorador_bosque_seco/features/puntos/domain/escaneo.dart';
import 'package:explorador_bosque_seco/features/sincronizacion/data/sincronizacion_repository_supabase.dart';
import 'package:explorador_bosque_seco/features/sincronizacion/domain/sincronizacion_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  late List<http.Request> pedidos;

  SincronizacionRepositorySupabase conServidor({
    int estado = 201,
    String cuerpo = '[]',
  }) {
    pedidos = [];
    final cliente = SupabaseClient(
      'https://ejemplo.supabase.co',
      'sb_publishable_prueba',
      httpClient: MockClient((pedido) async {
        pedidos.add(pedido);
        return http.Response(
          cuerpo,
          estado,
          headers: {'content-type': 'application/json; charset=utf-8'},
          request: pedido,
        );
      }),
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    addTearDown(cliente.dispose);
    return SincronizacionRepositorySupabase(cliente);
  }

  Escaneo sello(String visitaId) => Escaneo(
    id: nuevoId(),
    visitaId: visitaId,
    puntoId: 'mirador',
    fecha: DateTime(2026, 10, 11, 9),
  );

  test('los sellos se envían con upsert que ignora el mismo punto y visita '
      '(R1): reenviar no duplica', () async {
    final repositorio = conServidor();
    final escaneo = sello(nuevoId());

    final aceptados = await repositorio.enviarEscaneos([escaneo]);

    expect(aceptados, {escaneo.id});
    final pedido = pedidos.single;
    expect(pedido.url.path, '/rest/v1/scans');
    expect(pedido.url.queryParameters['on_conflict'], 'visit_id,point_id');
    expect(pedido.headers['Prefer'], contains('resolution=ignore-duplicates'));
  });

  test('los sellos de demostración no salen del celular', () async {
    final repositorio = conServidor();

    final aceptados = await repositorio.enviarEscaneos([sello('v-demo')]);

    expect(aceptados, isEmpty);
    expect(pedidos, isEmpty);
  });

  test('si el servidor no tiene las tablas, lo dice', () async {
    final repositorio = conServidor(
      estado: 404,
      cuerpo:
          '{"code":"PGRST205","details":null,"hint":null,'
          '"message":"Could not find the table \'public.scans\'"}',
    );

    expect(
      () => repositorio.enviarEscaneos([sello(nuevoId())]),
      throwsA(
        isA<SincronizacionFallida>().having(
          (f) => f.fallo,
          'fallo',
          FalloSincronizacion.sinTablas,
        ),
      ),
    );
  });
}
