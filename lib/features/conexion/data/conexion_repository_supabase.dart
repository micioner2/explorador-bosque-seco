import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/cliente_supabase.dart';
import '../domain/conexion_repository.dart';
import '../domain/estado_conexion.dart';

/// Prueba la conexión pidiendo una fila de las asociaciones a Supabase.
///
/// Una sola consulta responde las tres preguntas: si el servidor está al
/// alcance, si acepta la clave y si ya existen las tablas del portal.
class ConexionRepositorySupabase implements ConexionRepository {
  const ConexionRepositorySupabase(
    this._cliente, {
    this.tiempoMaximo = const Duration(seconds: 10),
  });

  /// Tabla del portal que siempre existe (la crea el equipo web) e indica
  /// si el esquema está listo. Con RLS puede responder vacía: igual cuenta
  /// como conectado.
  static const tablaDePrueba = 'associations';

  /// Códigos de PostgREST y Postgres para una tabla que no existe.
  static const _tablaInexistente = {'PGRST205', '42P01'};

  final SupabaseClient _cliente;
  final Duration tiempoMaximo;

  @override
  Future<EstadoConexion> verificar() async {
    try {
      await _cliente
          .from(tablaDePrueba)
          .select('id')
          .limit(1)
          .timeout(tiempoMaximo);
      return const Conectado(esquemaListo: true);
    } on PostgrestException catch (error) {
      final codigo = error.code ?? '';
      if (_tablaInexistente.contains(codigo)) {
        return const Conectado(esquemaListo: false);
      }
      if (codigo == '401' || codigo == '403') return const ClaveRechazada();
      return ErrorServidor(codigo);
    } on TimeoutException {
      return const SinConexion();
    } on SocketException {
      return const SinConexion();
    } on http.ClientException {
      return const SinConexion();
    }
  }
}

/// Repositorio para cuando la app no tiene servidor configurado.
class ConexionRepositorySinServidor implements ConexionRepository {
  const ConexionRepositorySinServidor();

  @override
  Future<EstadoConexion> verificar() async => const SinConfigurar();
}

/// Punto único donde se elige la implementación del repositorio: Supabase
/// si hay cliente, o ninguno si la app se compiló sin servidor.
final conexionRepositoryProvider = Provider<ConexionRepository>((ref) {
  final cliente = ref.watch(clienteSupabaseProvider);
  return cliente == null
      ? const ConexionRepositorySinServidor()
      : ConexionRepositorySupabase(cliente);
});
