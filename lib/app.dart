import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Raíz de la aplicación.
class BosqueSecoApp extends StatefulWidget {
  const BosqueSecoApp({super.key});

  @override
  State<BosqueSecoApp> createState() => _BosqueSecoAppState();
}

class _BosqueSecoAppState extends State<BosqueSecoApp> {
  late final GoRouter _router = crearRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Bosque Seco',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro,
      routerConfig: _router,
    );
  }
}
