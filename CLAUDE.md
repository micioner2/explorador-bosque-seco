# CLAUDE.md — Explorador ecoturístico del bosque seco (app móvil)

Contexto para Claude Code y para cualquier persona que se sume al proyecto.
Léelo completo antes de cambiar código.

## Qué es

App móvil en Flutter para el **Reto 12 de AIDER** (hackathon Piura Innova,
octubre 2026). Ayuda a que los turistas descubran el bosque seco de Piura y
contraten servicios de las comunidades, y reemplaza el cuaderno de visitas del
puesto de control por datos confiables.

- Propósito, usuarios, funcionalidades y alcance: [`docs/PRODUCTO.md`](docs/PRODUCTO.md)
- Arquitectura y decisiones técnicas: [`docs/ARQUITECTURA.md`](docs/ARQUITECTURA.md)

Este repositorio es **solo la app móvil**. La web informativa y el panel
administrativo viven en otro proyecto (web) que comparte la misma base de
datos (Supabase).

## Versiones fijas (no cambiar sin acordarlo con el equipo)

| Herramienta | Versión |
|---|---|
| Flutter | **3.38.9** stable (la misma del CI y de las laptops) |
| Dart | 3.10 |
| flutter_riverpod | ^3.3.2 |
| go_router | ^17.4.0 |
| Java (Android) | 17 |

Las versiones mayores nuevas de paquetes suelen exigir Dart 3.12: **no las
subas**. Antes de agregar un paquete, verifica en pub.dev que su versión
soporte Dart 3.10.

## Comandos

```bash
flutter pub get                 # dependencias
dart format lib test            # formato (el CI falla si hay cambios)
flutter analyze                 # análisis estático (el CI falla con infos)
flutter test                    # pruebas
flutter run                     # ejecutar en el celular/emulador
flutter build apk --release     # APK (el CI lo compila en main)
```

Antes de dar por terminado cualquier cambio, corre los tres primeros. La skill
`/verificar-calidad` lo hace por ti.

## Arquitectura (resumen)

MVVM con repositorios, organizada por funcionalidad (guía oficial de Flutter).

```
lib/features/<funcionalidad>/
├── domain/                  # Dart puro: modelos, reglas, interfaces de repositorio
├── data/                    # implementaciones de repositorios + su Provider
└── presentation/
    ├── view_models/         # Notifier/Provider de Riverpod
    └── views/               # pantallas (solo dibujan y delegan)
lib/core/                    # router (go_router), tema, reloj inyectable
lib/shared/widgets/          # widgets reutilizables
```

Reglas que no se rompen:

1. **Dependencias en un solo sentido:** `views → view_models → domain ← data`.
   `domain` no importa Flutter, Riverpod ni paquetes externos.
2. **Las reglas de negocio viven en `domain`** y se prueban ahí. Nunca en una
   vista ni en un repositorio.
3. **Las vistas no leen repositorios.** Solo `ref.watch(...ViewModelProvider)`
   y llaman métodos del ViewModel.
4. **Cada repositorio tiene interfaz en `domain`** (`abstract interface class`)
   y su `Provider` en `data`. Cambiar de datos demo a Supabase = cambiar el
   Provider, nada más.
5. **Modelos inmutables:** cada operación devuelve una copia nueva.
6. **La hora se obtiene de `relojProvider`**, nunca con `DateTime.now()` en
   lógica, para poder probarla.
7. **Rutas en `lib/core/router/rutas.dart`.** No escribas rutas como texto
   suelto.

Para crear una funcionalidad nueva usa la skill `/nueva-funcionalidad`.

## Offline-first (crítico para el reto)

Dentro del bosque no hay señal. Todo lo que el turista usa en el bosque debe
funcionar en modo avión:

- La fuente de verdad es la **base local del celular**; la red solo sincroniza.
- Todo registro creado en el celular lleva un **id generado en el celular**
  (UUID) y un estado `pendiente` → `confirmado`. Reenviar no debe duplicar.
- La interfaz muestra siempre si algo está pendiente de sincronizar.
- Prueba cada cambio de mapa, escaneo o sincronización en **modo avión**.

## Convenciones de código

- **Idioma:** dominio, UI, comentarios, pruebas y commits en **español**
  (`Visita`, `registrarEscaneo`, `sigueDentro`). Los términos propios de
  Flutter quedan en inglés (`build`, `Notifier`, `Provider`).
- El análisis es estricto (`analysis_options.yaml`): `strict-casts`,
  `strict-inference`, `strict-raw-types`, comillas simples, `const` donde se
  pueda, imports ordenados, sin `print`.
- Imports: primero `package:`, luego relativos, cada grupo en orden alfabético.
- Genéricos explícitos cuando no se infieren (`context.push<void>(...)`).
- Widgets privados (`_MiWidget`) en el mismo archivo de la vista que los usa;
  si se reutilizan, van a `lib/shared/widgets/`.
- Colores solo desde `AppColors` (`lib/core/theme/app_colors.dart`).
- Textos para personas de campo: frases cortas, botones grandes (mín. 48 px).

## Pruebas

- Toda regla nueva de `domain` lleva prueba unitaria en
  `test/features/<funcionalidad>/`.
- Los ViewModels se prueban con `ProviderContainer` sustituyendo repositorios y
  `relojProvider` (ver `test/features/visitas/visitas_view_model_test.dart`).
- Los nombres de las pruebas describen el comportamiento en español:
  `'escanear dos veces el mismo punto no suma de nuevo'`.

## Git y commits

- **Autor único:** los commits salen a nombre de
  `Mauricio Zapata Pella <38358253+micioner2@users.noreply.github.com>` (o del
  integrante que los hace). **No agregues líneas `Co-Authored-By` ni menciones
  a herramientas de IA** en commits ni en descripciones de PR.
  `.claude/settings.json` ya desactiva la atribución automática.
- Mensajes con prefijo convencional en español: `feat:`, `fix:`, `test:`,
  `docs:`, `refactor:`, `style:`, `ci:`, `chore:`.
- Ramas: `main` (estable para la presentación), `develop` (integración),
  `feature/<nombre>` (una por funcionalidad, PR hacia `develop`).
- Nunca hagas `push --force` a `main` ni a `develop`.
- Para preparar commits y PR usa la skill `/commit-y-pr`.

## Estado actual

- Datos de **demostración** en todos los repositorios (`*_repository_demo.dart`).
- Mapa y escáner son pantallas base: falta integrar `flutter_map` (teselas
  incluidas en la app) y `mobile_scanner`.
- **Supabase pendiente:** el equipo entregará las credenciales. No inventes
  URL ni claves; ver la skill `/integrar-supabase`.

## Skills del proyecto (`.claude/skills/`)

| Skill | Para qué |
|---|---|
| `/nueva-funcionalidad` | Crear una funcionalidad con sus capas, Provider, ruta y pruebas. |
| `/verificar-calidad` | Correr formato, análisis y pruebas como el CI. |
| `/reglas-negocio` | Consultar las reglas del dominio (puntos, visitas, reporte) y el glosario. |
| `/integrar-supabase` | Conectar los repositorios a Supabase cuando lleguen las credenciales. |
| `/commit-y-pr` | Preparar commits y pull requests con las convenciones del equipo. |

## Qué no hacer

- No subas credenciales, `.env` ni `google-services.json` al repositorio.
- No pongas lógica de negocio en vistas ni en repositorios.
- No uses `DateTime.now()` dentro de reglas o ViewModels.
- No agregues paquetes sin revisar compatibilidad con Dart 3.10.
- No cambies la versión de Flutter del CI (`.github/workflows/ci.yml`).
