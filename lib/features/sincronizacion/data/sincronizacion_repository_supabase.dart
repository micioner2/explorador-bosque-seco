import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/cliente_supabase.dart';
import '../../puntos/domain/escaneo.dart';
import '../../reportes/domain/cierre_dia.dart';
import '../../visitas/domain/visita.dart';
import '../domain/sincronizacion_repository.dart';

/// Sincronización con las tablas de `docs/supabase/sincronizacion-app.sql`
/// (visits, visitors, scans, day_closings). Upsert por id: reenviar no
/// duplica.
///
/// Solo se envían registros con id UUID: los datos de demostración ('v1',
/// 'v-demo') se quedan en el celular.
class SincronizacionRepositorySupabase implements SincronizacionRepository {
  const SincronizacionRepositorySupabase(
    this._cliente, {
    this.tiempoMaximo = const Duration(seconds: 20),
  });

  final SupabaseClient _cliente;
  final Duration tiempoMaximo;

  static final _uuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  static bool esUuid(String id) => _uuid.hasMatch(id);

  @override
  Future<Set<String>> enviarVisitas(Iterable<Visita> visitas) async {
    final enviables = [
      for (final v in visitas)
        if (esUuid(v.id) && esUuid(v.asociacionId)) v,
    ];
    if (enviables.isEmpty) return {};
    await _enviar(() async {
      await _cliente.from('visits').upsert([
        for (final v in enviables)
          {
            'id': v.id,
            'association_id': v.asociacionId,
            'guide_id': (v.guiaId != null && esUuid(v.guiaId!))
                ? v.guiaId
                : null,
            'guide_name': v.nombreGuia,
            'reservation_id': null,
            'activities': [for (final a in v.actividades) a.name],
            'entered_at': v.fechaEntrada.toUtc().toIso8601String(),
            'expected_exit_at': v.salidaPrevista.toUtc().toIso8601String(),
            'exited_at': v.fechaSalida?.toUtc().toIso8601String(),
          },
      ], onConflict: 'id');
      await _cliente.from('visitors').upsert([
        for (final v in enviables)
          for (final (i, persona) in v.integrantes.indexed)
            {
              'visit_id': v.id,
              'position': i + 1,
              'full_name': persona.nombre,
              'document_number': persona.documento,
              'age': persona.edad,
              'origin': persona.procedencia.name,
              'country': persona.pais,
            },
      ], onConflict: 'visit_id,position');
    });
    return {for (final v in enviables) v.id};
  }

  @override
  Future<Set<String>> enviarEscaneos(Iterable<Escaneo> escaneos) async {
    final enviables = [
      for (final e in escaneos)
        if (esUuid(e.id) && esUuid(e.visitaId)) e,
    ];
    if (enviables.isEmpty) return {};
    await _enviar(
      () => _cliente
          .from('scans')
          .upsert(
            [
              for (final e in enviables)
                {
                  'id': e.id,
                  'visit_id': e.visitaId,
                  'point_id': e.puntoId,
                  'scanned_at': e.fecha.toUtc().toIso8601String(),
                },
            ],
            // R1: el mismo punto en la misma visita ya está: se ignora.
            onConflict: 'visit_id,point_id',
            ignoreDuplicates: true,
          ),
    );
    return {for (final e in enviables) e.id};
  }

  @override
  Future<Set<String>> enviarCierres(Iterable<CierreDia> cierres) async {
    final enviables = [
      for (final c in cierres)
        if (esUuid(c.asociacionId)) c,
    ];
    if (enviables.isEmpty) return {};
    String dia(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
    await _enviar(
      () => _cliente.from('day_closings').upsert([
        for (final c in enviables)
          {
            'association_id': c.asociacionId,
            'day': dia(c.dia),
            'closed_at': c.cerradoEn.toUtc().toIso8601String(),
            'closed_by': c.cerradoPor,
            'groups': c.totalGrupos,
            'visitors': c.totalVisitantes,
            'groups_without_exit': c.gruposSinSalida,
            'by_guide': [
              for (final g in c.porGuia)
                {
                  'guide': g.nombreGuia,
                  'groups': g.grupos,
                  'people': g.personas,
                },
            ],
          },
      ], onConflict: 'association_id,day'),
    );
    return {for (final c in enviables) claveDeCierre(c)};
  }

  /// Clave con la que la app recuerda que un cierre ya se envió.
  static String claveDeCierre(CierreDia c) =>
      '${c.asociacionId}:${c.dia.year}-${c.dia.month}-${c.dia.day}';

  Future<void> _enviar(Future<void> Function() envio) async {
    try {
      await envio().timeout(tiempoMaximo);
    } on PostgrestException catch (error) {
      final codigo = error.code ?? '';
      if (codigo == 'PGRST205' || codigo == '42P01') {
        throw SincronizacionFallida(FalloSincronizacion.sinTablas, codigo);
      }
      throw SincronizacionFallida(FalloSincronizacion.rechazado, codigo);
    } on TimeoutException {
      throw const SincronizacionFallida(FalloSincronizacion.sinConexion);
    } on SocketException {
      throw const SincronizacionFallida(FalloSincronizacion.sinConexion);
    } on http.ClientException {
      throw const SincronizacionFallida(FalloSincronizacion.sinConexion);
    }
  }
}

/// `null` cuando la app se compiló sin servidor: no hay a dónde enviar y
/// el botón "Sincronizar ahora" no se muestra.
final sincronizacionRepositoryProvider = Provider<SincronizacionRepository?>((
  ref,
) {
  final cliente = ref.watch(clienteSupabaseProvider);
  return cliente == null ? null : SincronizacionRepositorySupabase(cliente);
});
