import 'package:go_router/go_router.dart';

import '../../features/escaneo/presentation/escanear_page.dart';
import '../../features/explorar/presentation/explorar_page.dart';
import '../../features/mapa/presentation/mapa_page.dart';
import '../../features/puntos/presentation/pasaporte_page.dart';
import '../../features/reportes/presentation/reporte_page.dart';
import '../../features/visitas/presentation/hoy_page.dart';
import '../../features/visitas/presentation/registrar_visitante_page.dart';
import 'rutas.dart';
import 'shells.dart';

/// Crea el enrutador de la app. Se crea por función (y no como global)
/// para que cada prueba tenga su propio estado de navegación.
GoRouter crearRouter() => GoRouter(
  initialLocation: Rutas.explorar,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => TuristaShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Rutas.explorar,
              builder: (context, state) => const ExplorarPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Rutas.mapa,
              builder: (context, state) => const MapaPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Rutas.pasaporte,
              builder: (context, state) => const PasaportePage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: Rutas.escanear,
      builder: (context, state) => const EscanearPage(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) =>
          AsociacionShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Rutas.asociacionHoy,
              builder: (context, state) => const HoyPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Rutas.asociacionRegistrar,
              builder: (context, state) => const RegistrarVisitantePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Rutas.asociacionReporte,
              builder: (context, state) => const ReportePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
