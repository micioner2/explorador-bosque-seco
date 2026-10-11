import 'package:go_router/go_router.dart';

import '../../features/escaneo/presentation/views/escanear_page.dart';
import '../../features/explorar/presentation/views/explorar_page.dart';
import '../../features/mapa/presentation/views/mapa_page.dart';
import '../../features/preferencias/presentation/views/ajustes_page.dart';
import '../../features/puntos/presentation/views/pasaporte_page.dart';
import '../../features/reportes/presentation/views/reporte_page.dart';
import '../../features/reservas/presentation/views/formulario_reserva_page.dart';
import '../../features/reservas/presentation/views/reservas_page.dart';
import '../../features/sesion/domain/sesion.dart';
import '../../features/sesion/presentation/views/acceso_page.dart';
import '../../features/sesion/presentation/views/elegir_guia_page.dart';
import '../../features/visitas/presentation/views/hoy_page.dart';
import '../../features/visitas/presentation/views/registrar_visitante_page.dart';
import 'rutas.dart';
import 'shells.dart';

/// Crea el enrutador de la app. Se crea por función (y no como global)
/// para que cada prueba tenga su propio estado de navegación.
///
/// [sesion] da la sesión actual; quien crea el router llama a
/// `GoRouter.refresh` cuando cambia, para volver a aplicar
/// [redirigirSegunSesion].
GoRouter crearRouter({required Sesion Function() sesion}) => GoRouter(
  initialLocation: Rutas.explorar,
  redirect: (context, state) => redirigirSegunSesion(sesion(), state.uri.path),
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
    GoRoute(
      path: Rutas.ajustes,
      builder: (context, state) => const AjustesPage(),
    ),
    GoRoute(
      path: Rutas.acceso,
      builder: (context, state) => const AccesoPage(),
    ),
    GoRoute(
      path: Rutas.accesoGuia,
      builder: (context, state) => const ElegirGuiaPage(),
    ),
    // El formulario de reservas se abre encima de la navegación inferior,
    // desde "Hoy" o desde "Reservas", y al guardar vuelve a donde estaba.
    GoRoute(
      path: Rutas.reservaNueva,
      builder: (context, state) => const FormularioReservaPage(),
    ),
    GoRoute(
      path: Rutas.reservaReprogramar,
      builder: (context, state) =>
          FormularioReservaPage(reservaId: state.pathParameters['id']),
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
              path: Rutas.asociacionReservas,
              builder: (context, state) => const ReservasPage(),
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

/// Lleva a cada persona al paso que le falta para usar el puesto de
/// control (reglas R11 y R12): primero la cuenta de la asociación, luego el
/// guía. Devuelve `null` si puede quedarse en [ruta].
///
/// Como la navegación sigue a la sesión, entrar, elegir guía, cambiar de
/// guía o salir de la cuenta solo cambian la sesión: el router hace el resto.
String? redirigirSegunSesion(Sesion sesion, String ruta) {
  final enAcceso = ruta == Rutas.acceso;
  final enGuia = ruta == Rutas.accesoGuia;
  final enAsociacion =
      ruta == Rutas.asociacionHoy || ruta.startsWith('${Rutas.asociacionHoy}/');
  if (!enAcceso && !enGuia && !enAsociacion) return null;

  if (!sesion.iniciada) return enAcceso ? null : Rutas.acceso;
  if (sesion.guia == null) return enGuia ? null : Rutas.accesoGuia;
  return enAsociacion ? null : Rutas.asociacionHoy;
}
