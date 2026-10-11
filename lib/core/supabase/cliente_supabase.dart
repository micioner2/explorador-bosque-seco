import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config_supabase.dart';

/// Cliente de Supabase que usan los repositorios de la capa `data`.
///
/// Es `null` cuando la app se compiló sin configuración o no se pudo
/// iniciar: entonces los repositorios usan los datos del celular. `main.dart`
/// lo sustituye por el cliente real al arrancar.
final clienteSupabaseProvider = Provider<SupabaseClient?>((ref) => null);

/// Inicia Supabase si la app se compiló con su configuración.
///
/// No necesita señal: solo prepara el cliente y la sesión guardada. Si algo
/// falla, devuelve `null` y la app sigue funcionando sin servidor.
Future<SupabaseClient?> iniciarSupabase() async {
  if (!ConfigSupabase.configurada) return null;
  try {
    final supabase = await Supabase.initialize(
      url: ConfigSupabase.url,
      publishableKey: ConfigSupabase.clavePublica,
    );
    return supabase.client;
  } on Exception catch (error) {
    debugPrint('No se pudo iniciar Supabase: $error');
    return null;
  }
}
