import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/l10n/l10n.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/preferencias/domain/preferencias.dart';
import 'features/preferencias/presentation/view_models/preferencias_view_model.dart';
import 'features/sesion/presentation/view_models/sesion_view_model.dart';
import 'features/sincronizacion/presentation/view_models/sincronizacion_view_model.dart';

/// Raíz de la aplicación. Aplica el idioma y la apariencia que la persona
/// eligió en Ajustes, y lleva al puesto de control solo con sesión.
class BosqueSecoApp extends ConsumerStatefulWidget {
  const BosqueSecoApp({super.key});

  @override
  ConsumerState<BosqueSecoApp> createState() => _BosqueSecoAppState();
}

class _BosqueSecoAppState extends ConsumerState<BosqueSecoApp> {
  late final GoRouter _router = crearRouter(
    sesion: () => ref.read(sesionViewModelProvider),
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Al entrar, elegir guía o salir, el router lleva a la pantalla que toca.
    ref.listen(sesionViewModelProvider, (_, _) => _router.refresh());
    // El estado de conexión se mantiene vivo desde la raíz: así sigue al día
    // aunque la pestaña que lo muestra esté oculta (Riverpod pausa a quien
    // escucha desde una pestaña oculta y, al volver, no puede reconstruir
    // proveedores compartidos a mitad del dibujo).
    ref.listen(estadoPuestoProvider, (_, _) {});
    ref.listen(estadoTuristaProvider, (_, _) {});
    ref.listen(sincronizacionDisponibleProvider, (_, _) {});
    // Al volver la señal se envía solo lo pendiente.
    ref.listen(hayRedProvider, (antes, ahora) {
      if (ahora == true && antes != true) {
        ref.read(sincronizacionViewModelProvider.notifier).sincronizar();
      }
    });
    final preferencias = ref.watch(preferenciasViewModelProvider);
    final idioma = preferencias.idioma;

    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitulo,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro,
      darkTheme: AppTheme.oscuro,
      themeMode: switch (preferencias.modoTema) {
        ModoTema.sistema => ThemeMode.system,
        ModoTema.claro => ThemeMode.light,
        ModoTema.oscuro => ThemeMode.dark,
      },
      // Sin idioma elegido se usa el del celular; si no está traducido,
      // Flutter toma el primero de la lista (español).
      locale: idioma == null ? null : Locale(idioma.codigo),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
      // Android 15+ dibuja la app detrás de la barra de botones del
      // sistema. Se deja ese espacio libre en todas las pantallas para que
      // los botones del celular no tapen el contenido.
      builder: (context, child) => ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          top: false,
          left: false,
          right: false,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
