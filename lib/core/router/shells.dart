import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'rutas.dart';

/// Navegación inferior del modo turista, con el botón de escanear al centro.
class TuristaShell extends StatelessWidget {
  const TuristaShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _irA(int indice) => navigationShell.goBranch(
    indice,
    initialLocation: indice == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Escanear QR',
        onPressed: () => context.push<void>(Rutas.escanear),
        child: const Icon(Icons.qr_code_scanner),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _irA,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explorar',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.workspace_premium_outlined),
            selectedIcon: Icon(Icons.workspace_premium),
            label: 'Pasaporte',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Hoy'),
          NavigationDestination(
            icon: Icon(Icons.person_add_alt),
            label: 'Registrar',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Reporte',
          ),
        ],
      ),
    );
  }
}
