import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'features/preferencias/data/preferencias_repository_local.dart';
import 'features/preferencias/data/preferencias_repository_memoria.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final almacen = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        preferenciasRepositoryProvider.overrideWithValue(
          PreferenciasRepositoryLocal(almacen),
        ),
      ],
      child: const BosqueSecoApp(),
    ),
  );
}
