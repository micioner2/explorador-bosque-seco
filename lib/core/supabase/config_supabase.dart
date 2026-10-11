/// Datos de conexión con Supabase.
///
/// No se escriben en el código: se pasan al compilar con
/// `--dart-define-from-file=config/supabase.json` (copia de
/// `config/supabase.example.json`, ignorada por git). Si faltan, la app
/// funciona solo con los datos guardados en el celular.
abstract final class ConfigSupabase {
  static const url = String.fromEnvironment('SUPABASE_URL');

  /// Clave pública (`sb_publishable_...`). Nunca la clave secreta ni la
  /// `service_role`: la app se instala en celulares de terceros.
  static const clavePublica = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static bool get configurada => url.isNotEmpty && clavePublica.isNotEmpty;
}
