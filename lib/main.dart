import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/supabase/cliente_supabase.dart';
import 'features/preferencias/data/preferencias_repository_local.dart';
import 'features/preferencias/data/preferencias_repository_memoria.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final almacen = await SharedPreferences.getInstance();
  // `null` si la app se compiló sin config/supabase.json.
  final clienteSupabase = await iniciarSupabase();

  runApp(
    ProviderScope(
      overrides: [
        preferenciasRepositoryProvider.overrideWithValue(
          PreferenciasRepositoryLocal(almacen),
        ),
        if (clienteSupabase != null)
          clienteSupabaseProvider.overrideWithValue(clienteSupabase),
      ],
      child: const BosqueSecoApp(),
    ),
  );
}
