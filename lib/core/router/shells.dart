import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/l10n.dart';
import 'rutas.dart';

/// Navegación inferior del modo turista, con el botón de escanear siempre
/// a la mano: es la acción principal dentro del bosque.
class TuristaShell extends StatelessWidget {
  const TuristaShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _irA(int indice) => navigationShell.goBranch(
    indice,
    initialLocation: indice == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: navigationShell,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push<void>(Rutas.escanear),
        icon: const Icon(Icons.qr_code_scanner),
        label: Text(l10n.escanearQr),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _irA,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            selectedIcon: const Icon(Icons.explore),
            label: l10n.navExplorar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            label: l10n.navMapa,
          ),
          NavigationDestination(
            icon: const Icon(Icons.workspace_premium_outlined),
            selectedIcon: const Icon(Icons.workspace_premium),
            label: l10n.navPasaporte,
          ),
        ],
      ),
    );
  }
}

/// Navegación inferior del modo asociación (puesto de control).
class AsociacionShell extends StatelessWidget {
  const AsociacionShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _irA(int indice) => navigationShell.goBranch(
    indice,
    initialLocation: indice == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _irA,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.groups_outlined),
            selectedIcon: const Icon(Icons.groups),
            label: l10n.navHoy,
          ),
          NavigationDestination(
            icon: const Icon(Icons.event_outlined),
            selectedIcon: const Icon(Icons.event),
            label: l10n.navReservas,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_add_alt_1_outlined),
            selectedIcon: const Icon(Icons.person_add_alt_1),
            label: l10n.navRegistrar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.insert_chart_outlined),
            selectedIcon: const Icon(Icons.insert_chart),
            label: l10n.navReporte,
          ),
        ],
      ),
    );
  }
}
