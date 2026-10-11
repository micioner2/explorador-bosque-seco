# Explorador ecoturístico del bosque seco

[![CI](https://github.com/micioner2/explorador-bosque-seco/actions/workflows/ci.yml/badge.svg)](https://github.com/micioner2/explorador-bosque-seco/actions/workflows/ci.yml)

App móvil para el **Reto 12 de AIDER** en el hackathon **Piura Innova**: que los
turistas descubran el bosque seco de Piura y que las asociaciones dejen el
cuaderno de visitas por datos confiables.

## Documentación

| Documento | Contenido |
|---|---|
| [`CLAUDE.md`](CLAUDE.md) | Contexto de desarrollo: versiones, comandos, reglas de arquitectura, convenciones y skills de Claude Code. |
| [`docs/PRODUCTO.md`](docs/PRODUCTO.md) | Propósito, usuarios, funcionalidades, alcance y reglas de negocio de la app móvil. |
| [`docs/ARQUITECTURA.md`](docs/ARQUITECTURA.md) | Arquitectura elegida, alternativas evaluadas y diseño offline-first. |
| [`.claude/skills/`](.claude/skills) | Skills del proyecto para Claude Code. |

## El problema

- **Difusión:** el turista no conoce los senderos, el avistamiento de fauna ni
  los servicios de las comunidades. Para contactar a un guía hay que preguntar
  a SERNANP, que deriva al presidente de la asociación, que pasa el celular del
  guía.
- **Registro:** en el puesto de control los visitantes se anotan a mano en un
  cuaderno. La letra no se entiende y no hay estadísticas para planificar ni
  para postular a fondos como Procompite.
- **Sin señal:** dentro del bosque no hay internet; en el pueblo y en el puesto
  de control sí.

## La solución

| Modo | Qué hace |
|---|---|
| **Turista** | Explora rutas, atractivos y servicios; contacta a guías por WhatsApp; ve el siguiente punto con su distancia y tiempo, también sin señal; escanea el QR de cada punto y gana puntos. |
| **Asociación** | Registra a cada integrante de un grupo desde una sola pantalla y genera **un único QR** para todos; ve quién sigue dentro del bosque, canjea puntos y genera el reporte diario. |

**Para todos:** la app está en **español e inglés** y tiene **modo claro y
oscuro** (o el del celular). Se eligen en Ajustes y se guardan en el celular.
Está pensada para usarse al sol: contraste AA, botones de 48 px y pantallas
que no se rompen con letra grande.

**Puntos y canje:** cada punto turístico escaneado da 1 punto por visita. Los
puntos confirmados se canjean por descuentos en productos de la comunidad
(polos, miel, artesanía). Así cada visita termina en una venta para la
comunidad.

## Arquitectura

**MVVM con repositorios, organizada por funcionalidad**: la arquitectura que
recomienda la [guía oficial de Flutter](https://docs.flutter.dev/app-architecture/guide).
La evaluación de alternativas y el diseño offline-first están en
[`docs/ARQUITECTURA.md`](docs/ARQUITECTURA.md).

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── reloj.dart                  # hora inyectable para pruebas
│   ├── l10n/                       # acceso a traducciones y formatos
│   ├── router/                     # go_router: rutas y navegación por modo
│   └── theme/                      # paleta, tema claro/oscuro y medidas
├── l10n/                           # textos: app_es.arb y app_en.arb
├── features/
│   └── <funcionalidad>/
│       ├── domain/                 # modelos, reglas e interfaces (Dart puro)
│       ├── data/                   # implementaciones de repositorios
│       └── presentation/
│           ├── view_models/        # estado y acciones (Riverpod Notifier)
│           └── views/              # pantallas
└── shared/widgets/                 # componentes reutilizables
test/                               # dominio, ViewModels y widgets
```

Funcionalidades: `explorar`, `mapa`, `escaneo`, `puntos`, `visitas`,
`reportes`, `preferencias` y `conexion`.

**Stack:** Flutter 3.38.9 (Dart 3.10) · Riverpod 3 · go_router ·
flutter_localizations (es/en) · shared_preferences · qr_flutter ·
Supabase (`supabase_flutter`).

### Reglas de negocio con pruebas

- Un punto turístico suma una sola vez por visita, aunque se escanee varias
  veces o el escaneo llegue duplicado al sincronizar.
- Solo los puntos confirmados por el servidor se pueden canjear.
- Un grupo que pasó su hora de salida y no la marcó genera la alerta
  "sigue dentro".
- Un grupo hace una o varias actividades y comparte un solo QR; cada
  integrante se registra con su propia edad y procedencia.
- El reporte diario cuenta personas, procedencia y rango de edad de cada
  integrante, y los puntos más visitados.
- El siguiente punto de la ruta es el primero sin sello.

## Cómo ejecutar

Requisitos: Flutter **3.38.9** (canal stable) y un celular o emulador Android.

```bash
flutter pub get      # también genera las traducciones
flutter run          # solo datos de demostración
```

**Con Supabase:** copia `config/supabase.example.json` como
`config/supabase.json` (no se sube al repositorio), completa la URL y la
clave pública del proyecto y ejecuta:

```bash
flutter run --dart-define-from-file=config/supabase.json
flutter test --tags supabase --dart-define-from-file=config/supabase.json  # prueba de conexión
```

El estado de la conexión también se ve en **Ajustes → Servidor**.

Si editas un texto en `lib/l10n/*.arb`, regenera las traducciones con
`flutter gen-l10n`.

Validaciones locales (las mismas que corre el CI):

```bash
dart format lib test
flutter analyze
flutter test
```

## Integración continua

El workflow [`ci.yml`](.github/workflows/ci.yml) corre en cada *push* y en cada
*pull request*:

1. **Dependencias exactas:** `flutter pub get --enforce-lockfile` (falla si
   `pubspec.lock` no corresponde a `pubspec.yaml`).
2. **Traducciones:** `flutter gen-l10n` genera los textos en español e inglés.
3. **Formato:** `dart format --set-exit-if-changed`.
4. **Análisis estático:** `flutter analyze` con reglas estrictas
   (`analysis_options.yaml`).
5. **Pruebas:** `flutter test --coverage`: dominio, ViewModels, recorridos de
   pantalla, contraste de los dos temas, traducciones completas y
   accesibilidad (claro/oscuro, español/inglés, letra grande). El resumen de
   la ejecución muestra el porcentaje de cobertura.
6. **Compilación:** `flutter build apk --release`. El APK queda como artefacto
   descargable de la ejecución.

## Flujo de trabajo en Git

- `main`: versión estable para la presentación.
- `develop`: integración del equipo.
- `feature/<nombre>`: una rama por funcionalidad, con *pull request* hacia
  `develop`.

Commits con prefijos convencionales: `feat:`, `fix:`, `test:`, `docs:`,
`ci:`, `refactor:`.

## Equipo

Desarrollo, datos y soluciones para el hackathon Piura Innova 2026.
