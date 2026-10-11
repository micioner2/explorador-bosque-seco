# Arquitectura

La app sigue la **arquitectura recomendada por el equipo de Flutter**
([guía oficial](https://docs.flutter.dev/app-architecture/guide)): MVVM con
capa de datos basada en repositorios, organizada **por funcionalidad**
(*feature-first*) y con Riverpod para el estado y la inyección de
dependencias.

## Alternativas evaluadas

| Opción | Motivo de la decisión |
|---|---|
| Lógica en widgets (`setState`) | Descartada: no se puede probar y crece sin control. |
| GetX | Descartada: mezcla navegación, estado e inyección y oculta dependencias. |
| Clean Architecture completa (casos de uso, DTOs, mappers) | Descartada: demasiado código repetitivo para el alcance y el tiempo del hackathon. |
| BLoC por capas | Viable, pero cada pantalla requiere eventos y estados explícitos: más lento de construir. |
| **MVVM + repositorios, por funcionalidad (Riverpod)** | **Elegida:** es la guía oficial, separa reglas de interfaz, se prueba fácil y permite que cada integrante trabaje en su carpeta. |

## Capas

Las dependencias van en un solo sentido: `views → view_models → domain ← data`.

```
features/<funcionalidad>/
├── domain/                  # Dart puro: modelos, reglas e interfaces
│   ├── <modelo>.dart
│   └── <x>_repository.dart  # contrato (abstract interface class)
├── data/                    # implementaciones de los repositorios
│   └── <x>_repository_demo.dart
└── presentation/
    ├── view_models/         # Notifier de Riverpod: estado y acciones
    └── views/               # pantallas: solo dibujan y delegan
```

| Capa | Responsabilidad | No debe |
|---|---|---|
| `views` | Dibujar el estado y llamar acciones del ViewModel. | Tener reglas de negocio ni acceder a repositorios. |
| `view_models` | Exponer el estado de la pantalla y coordinar acciones. | Conocer widgets ni detalles de la base de datos. |
| `domain` | Reglas del negocio (puntos, canje, alertas, reporte). | Depender de Flutter o de paquetes externos. |
| `data` | Obtener y guardar datos (demo, base local, API). | Contener reglas de negocio. |

## Offline-first

Dentro del bosque no hay señal, así que la capa de datos se diseña así:

1. **Base local como fuente de verdad.** Los repositorios leen siempre del
   celular. La interfaz no sabe si hay internet.
2. **Cola de pendientes.** Los escaneos y registros se guardan con un
   identificador generado en el celular y estado `pendiente`.
3. **Sincronización al volver la señal.** Un servicio envía la cola al
   servidor; como cada registro tiene su propio id, reenviarlo no lo duplica.
   La respuesta confirma los escaneos (`PasaporteViewModel.confirmar`).

Cambiar los datos de demostración por la base local o la API solo toca la
capa `data` y el *provider* del repositorio: ni las pantallas ni las reglas
cambian.

### Conexión con Supabase

- La URL y la clave pública se pasan al compilar
  (`--dart-define-from-file=config/supabase.json`) y se leen en
  `core/supabase/config_supabase.dart`. El archivo no se sube al
  repositorio.
- `main.dart` llama a `iniciarSupabase()`: si no hay configuración o falla,
  devuelve `null` y la app arranca igual. No necesita señal.
- `clienteSupabaseProvider` es el único punto de acceso al cliente. El
  Provider de cada repositorio elige la versión Supabase si hay cliente, o
  la de demostración si no.
- `features/conexion` prueba el servidor con una consulta liviana y
  distingue: conectado (con o sin esquema), clave rechazada, sin conexión y
  error del servidor. Nunca lanza excepciones; se muestra en Ajustes.

### Sesión de la asociación (funciona sin señal)

`features/sesion` maneja quién usa el puesto de control: la **cuenta de la
asociación** y el **guía** que eligió su nombre.

| Momento | ¿Señal? | Qué pasa |
|---|---|---|
| Entrar por primera vez | Sí | `SesionRepositorySupabase` entra con Supabase Auth, lee `profiles.association_id` y el nombre en `associations`, y los guarda en el celular (`shared_preferences`). |
| Abrir la app después | No | `Supabase.initialize` recupera su sesión del celular sin conectarse y `cuentaGuardada()` devuelve la cuenta. Si el pase vence sin señal, Supabase **no** cierra la sesión: la renueva cuando vuelve la señal. |
| Elegir guía, registrar | No | La lista de guías se lee del celular. Cada visita guarda la asociación y el guía. |
| Salir de la cuenta | No | Se borra del celular primero; si no hay señal, el aviso al servidor falla y la sesión del servidor vence sola. |

Este comportamiento se comprobó en el código de `gotrue` 2.27.3: solo se
cierra la sesión si el servidor rechaza el pase, no ante un error de red.

- **Navegación guiada por el estado.** `redirigirSegunSesion` (en
  `core/router/app_router.dart`) lleva al acceso si no hay cuenta y a
  "¿Quién eres?" si falta el guía. `app.dart` llama a `GoRouter.refresh`
  cuando cambia la sesión: entrar, elegir guía, cambiar de guía o salir solo
  cambian el `SesionViewModel` y el router hace el resto.
- **Sin servidor** (`flutter run` sin configuración, pruebas y CI) se usa
  `SesionRepositoryDemo`, que acepta solo la cuenta de prueba que muestra la
  pantalla de acceso. `main.dart` sustituye el repositorio por el de
  Supabase cuando hay cliente.
- **Pendiente:** la tabla de guías en Supabase (hoy `GuiasRepositoryDemo`),
  el rol de la cuenta en `profiles` y el cierre diario.

### Reservas y su conversión en ingreso

`features/reservas` guarda las reservas y arma la agenda (`AgendaReservas`:
no llegaron, hoy y próximos días). La conversión en ingreso reutiliza el
registro de grupos en lugar de duplicarlo:

1. "Llegaron" (`TarjetaReserva`) llama a
   `RegistroGrupoViewModel.atenderReserva(id)` y abre la pestaña Registrar.
2. El registro muestra la reserva (`reservaEnAtencionProvider`) y propone el
   nombre de quien reservó como responsable.
3. `RegistroGrupoViewModel.registrar()` crea la visita con su `reservaId` y
   marca la reserva como `ingresada` con el id de la visita.

La dependencia va en un solo sentido entre ViewModels: `visitas` usa
`reservas`, nunca al revés. Las reservas nuevas llevan un id generado en el
celular (`core/id.dart`), listo para la sincronización sin duplicados.

## Interfaz: tema, idiomas y preferencias

La capa `views` no decide colores ni textos; los pide.

| Tema | Dónde vive | Cómo se usa en una vista |
|---|---|---|
| Colores (claro y oscuro) | `core/theme/app_theme.dart` arma dos `ThemeData` con la paleta de `AppColors`. Lo que Material no cubre (cabecera, aviso sin señal, barra de la asociación) está en `ColoresApp`, una `ThemeExtension`. | `context.esquema.primary`, `context.colores.aviso` |
| Medidas | `core/theme/app_espacios.dart` | `AppEspacios.l` |
| Textos (español e inglés) | `lib/l10n/app_es.arb` (plantilla) y `app_en.arb`. Flutter genera `AppLocalizations` con `flutter gen-l10n` (configurado en `l10n.yaml`). | `context.l10n.navExplorar` |
| Textos de los `enum` del dominio | `core/l10n/etiquetas_dominio.dart`: el dominio sigue siendo Dart puro y sin textos de interfaz. | `actividad.texto(l10n)` |
| Distancias y duraciones | `core/l10n/formato.dart` | `formatearDistancia(1200, 'es')` → `1,2 km` |

**Preferencias** (`features/preferencias`) es una funcionalidad más, con sus
capas: `Preferencias` (idioma y modo de tema) en `domain`,
`PreferenciasRepositoryLocal` (`shared_preferences`) en `data` y
`PreferenciasViewModel` en `presentation`. `app.dart` observa ese ViewModel y
aplica `locale` y `themeMode`. Como el almacenamiento se abre de forma
asíncrona, `main.dart` lo carga antes de arrancar y sustituye el Provider del
repositorio; sin esa sustitución (pruebas) se usa uno en memoria.

Los archivos `lib/l10n/app_localizations*.dart` son generados: no se suben
al repositorio. Los crea `flutter pub get` (por `generate: true` en
`pubspec.yaml`) y el CI los regenera.

**Contenido de la asociación.** Los nombres de atractivos, servicios y
tarifas vienen de los repositorios y se muestran tal como se cargaron.
Traducirlos requiere columnas por idioma en la base de datos; es una decisión
pendiente con el proyecto web.

## Pruebas

- `test/features/*/` prueba el dominio (reglas puras) y los ViewModels con
  `ProviderContainer`, sustituyendo repositorios y reloj por dobles de prueba.
- `test/app_test.dart` prueba los recorridos principales con widgets:
  navegación, escaneo, canje, registro de un grupo con su QR, cambio de
  idioma y de tema.
- `test/accesibilidad_test.dart` revisa cada pantalla en claro y oscuro
  (contraste de texto, áreas táctiles de 48 px, etiquetas para lector de
  pantalla) y que no se desborde en un celular pequeño con letra grande, en
  español e inglés.
- `test/core/theme/app_theme_test.dart` calcula el contraste WCAG de cada
  pareja texto/fondo de los dos temas.
- `test/l10n/traducciones_test.dart` compara los dos `.arb`: mismas claves,
  mismas variables y ningún texto vacío.
- `test/features/conexion/` y `test/features/sesion/` simulan el servidor
  de Supabase con `MockClient` (sin red), incluidos la falta de señal, la
  demora y salir de la cuenta sin conexión. `test/integracion/` llama al servidor real y solo corre con
  `--tags supabase --dart-define-from-file=config/supabase.json`; en el CI
  se omite.
