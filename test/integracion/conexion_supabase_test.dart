// Prueba contra el servidor real de Supabase. Solo corre si se pasa la
// configuración; sin ella (por ejemplo, en el CI) se omite, porque las
// pruebas normales no usan la red:
//
//   flutter test --tags supabase --dart-define-from-file=config/supabase.json
@Tags(['supabase'])
library;

import 'package:explorador_bosque_seco/core/supabase/config_supabase.dart';
import 'package:explorador_bosque_seco/features/conexion/data/conexion_repository_supabase.dart';
import 'package:explorador_bosque_seco/features/conexion/domain/estado_conexion.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test(
    'el servidor de Supabase responde y acepta la clave de la app',
    () async {
      final cliente = SupabaseClient(
        ConfigSupabase.url,
        ConfigSupabase.clavePublica,
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      );
      addTearDown(cliente.dispose);

      final estado = await ConexionRepositorySupabase(cliente).verificar();

      expect(estado, isA<Conectado>(), reason: 'Resultado: $estado');
      final listo = (estado as Conectado).esquemaListo;
      debugPrint(
        'Supabase: conectado · esquema de la base '
        '${listo ? 'listo' : 'pendiente (faltan las tablas)'}',
      );
    },
    skip: ConfigSupabase.configurada
        ? false
        : 'Sin configuración: usa --dart-define-from-file=config/supabase.json',
  );
}
