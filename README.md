# Explorador ecoturístico del bosque seco

[![CI](https://github.com/micioner2/explorador-bosque-seco/actions/workflows/ci.yml/badge.svg)](https://github.com/micioner2/explorador-bosque-seco/actions/workflows/ci.yml)

App móvil para el **Reto 12 de AIDER** en el hackathon **Piura Innova**: que los
turistas descubran el bosque seco de Piura y que las asociaciones dejen el
cuaderno de visitas por datos confiables.

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
| **Turista** | Explora rutas, atractivos y servicios; contacta a guías por WhatsApp; ve el mapa con GPS sin señal; escanea el QR de cada punto y gana puntos. |
| **Asociación** | Registra visitantes en menos de un minuto, ve quién sigue dentro del bosque, canjea puntos y genera el reporte diario. |

**Puntos y canje:** cada punto turístico escaneado da 1 punto por visita. Los
puntos confirmados se canjean por descuentos en productos de la comunidad
(polos, miel, artesanía). Así cada visita termina en una venta para la
comunidad.

## Arquitectura

Organizada por funcionalidades (*feature-first*). Cada una separa:

- `domain/`: entidades y reglas de negocio puras en Dart, sin Flutter. Es
  la parte cubierta por las pruebas unitarias.
- `data/`: repositorios y proveedores de datos (hoy, datos de demostración).
- `presentation/`: pantallas y widgets.

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── reloj.dart              # hora inyectable para pruebas
│   ├── router/                 # go_router: rutas y navegación por modo
│   └── theme/                  # paleta y tema
├── features/
│   ├── explorar/               # espacio, atractivos y servicios
│   ├── mapa/                   # mapa de la ruta sin señal
│   ├── escaneo/                # lector de QR de los puntos
│   ├── puntos/                 # pasaporte, reglas de puntos y canje
│   ├── visitas/                # registro, salida y alerta "sigue dentro"
│   └── reportes/               # reporte diario
└── shared/widgets/             # componentes reutilizables
test/                           # pruebas unitarias y de widgets
```

**Stack:** Flutter 3.38.9 (Dart 3.10) · Riverpod · go_router.

### Reglas de negocio con pruebas

- Un punto turístico suma una sola vez por visita, aunque se escanee varias
  veces o el escaneo llegue duplicado al sincronizar.
- Solo los puntos confirmados por el servidor se pueden canjear.
- Un grupo que pasó su hora de salida y no la marcó genera la alerta
  "sigue dentro".
- El reporte diario cuenta personas, procedencia, rangos de edad y los puntos
  más visitados.

## Cómo ejecutar

Requisitos: Flutter **3.38.9** (canal stable) y un celular o emulador Android.

```bash
flutter pub get
flutter run
```

Validaciones locales (las mismas que corre el CI):

```bash
dart format lib test
flutter analyze
flutter test
```

## Integración continua

El workflow [`ci.yml`](.github/workflows/ci.yml) corre en cada *push* y en cada
*pull request*:

1. **Formato:** `dart format --set-exit-if-changed`.
2. **Análisis estático:** `flutter analyze` con reglas estrictas
   (`analysis_options.yaml`).
3. **Pruebas:** `flutter test --coverage`.
4. **Compilación:** `flutter build apk --release`. El APK queda como artefacto
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
