import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/almacen/almacen_local.dart';
import 'core/supabase/cliente_supabase.dart';
import 'features/preferencias/data/preferencias_repository_local.dart';
import 'features/preferencias/data/preferencias_repository_memoria.dart';
import 'features/sesion/data/sesion_repository_demo.dart';
import 'features/sesion/data/sesion_repository_supabase.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final almacen = await SharedPreferences.getInstance();
  // `null` si la app se compiló sin config/supabase.json. Si había una
  // sesión guardada, ya quedó recuperada (sin necesitar señal).
  final clienteSupabase = await iniciarSupabase();

  runApp(
    ProviderScope(
      overrides: [
        almacenLocalProvider.overrideWithValue(AlmacenPreferencias(almacen)),
        preferenciasRepositoryProvider.overrideWithValue(
          PreferenciasRepositoryLocal(almacen),
        ),
        if (clienteSupabase != null) ...[
          clienteSupabaseProvider.overrideWithValue(clienteSupabase),
          sesionRepositoryProvider.overrideWithValue(
            SesionRepositorySupabase(clienteSupabase, almacen),
          ),
        ],
      ],
      child: const BosqueSecoApp(),
    ),
  );
}
