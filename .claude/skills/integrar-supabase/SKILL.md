---
name: integrar-supabase
description: Conecta los repositorios de la app a Supabase (Postgres, Auth, Storage) manteniendo el funcionamiento offline-first. La conexión y su prueba ya están hechas; falta el esquema y los repositorios. Úsala al configurar Supabase, crear el esquema, escribir repositorios Supabase o implementar la sincronización.
---

# Integrar Supabase

> **Estado:** conexión hecha y probada (servidor y clave OK). El portal web
> ya creó `associations`, `profiles`, `routes`, `services` y `media`, en
> inglés y con columnas `_es`/`_en`: **las tablas nuevas siguen esa
> convención** (no los nombres en español de `referencia-esquema.sql`) y se
> acuerdan con el equipo web. El acceso de la asociación ya usa Supabase
> Auth (`features/sesion`). El resto de repositorios siguen en
> `*_repository_demo.dart`. No inventes URL ni claves: las reales están en
> `config/supabase.json`.

## 1. Configuración (sin subir secretos)

- La URL y la **clave pública** (`sb_publishable_...`) van en
  `config/supabase.json` (ignorado por git), copiando
  `config/supabase.example.json`.
- Se pasan al compilar con `--dart-define-from-file=config/supabase.json` y
  se leen en `lib/core/supabase/config_supabase.dart` (`SUPABASE_URL` y
  `SUPABASE_PUBLISHABLE_KEY`).
- Nunca uses la clave secreta ni la `service_role` en la app: el APK se
  instala en celulares de terceros. La seguridad la dan las políticas RLS.

## 2. Paquete y cliente (hecho)

- `supabase_flutter: ^2.18.2` (compatible con Dart 3.10). En Windows,
  `flutter pub add paquete:^x` pierde el `^`: revisa `pubspec.yaml`.
- `iniciarSupabase()` (`lib/core/supabase/cliente_supabase.dart`) se llama
  en `main.dart` solo si hay configuración. No necesita señal y, si falla,
  la app sigue con datos demo.
- **`clienteSupabaseProvider`** es el único punto de acceso al cliente. Los
  repositorios Supabase lo leen en su Provider: si es `null`, usan la
  versión demo (ver `conexionRepositoryProvider` como ejemplo).

## Prueba de conexión (hecha)

- `features/conexion`: una consulta a `espacios` distingue servidor
  conectado con o sin esquema, clave rechazada, sin conexión y error del
  servidor. Se ve en Ajustes → Servidor.
- Pruebas sin red con `MockClient` en `test/features/conexion/`.
- Contra el servidor real (se omite sin configuración, como en el CI):
  `flutter test --tags supabase --dart-define-from-file=config/supabase.json`.

## Acceso de la asociación (hecho)

- `SesionRepositorySupabase` entra con `signInWithPassword`, lee
  `profiles.association_id` del usuario y `associations.name`/`is_active`, y
  guarda la cuenta en el celular. `main.dart` lo usa cuando hay cliente.
- Sin señal, Supabase recupera su sesión del celular y no la cierra por
  errores de red (comprobado en `gotrue` 2.27.3). Salir de la cuenta borra
  primero la sesión del celular.
- Pruebas sin red en `test/features/sesion/sesion_repository_supabase_test.dart`.
- Pendiente con el equipo web: tabla de guías por asociación, valores de
  `profiles.role`, regla RLS para que cada cuenta lea su propio perfil y
  desactivar el registro abierto de usuarios.
- Pendiente: tabla de reservas (por ejemplo `reservations`, con
  `association_id`, `contact_name`, `phone`, `scheduled_at`, `people`,
  `status`, `reschedules`, `visit_id`, `guide_id`). El `id` lo genera el
  celular (UUID) para que reenviar no duplique; `status` solo avanza de
  `pending` a `cancelled` o `checked_in` (R14 y R15). El teléfono es dato
  personal: solo lo lee la asociación dueña (RLS).

## 3. Esquema y seguridad

Usa como base `referencia-esquema.sql` (en esta carpeta). Lo esencial:

- `escaneos.id` es el UUID generado en el celular y lleva
  `UNIQUE (visita_id, punto_id)`, que es la regla R1 en la base de datos.
- El canje es una **función SQL** (`canjear_producto`) que valida puntos y
  descuenta en una sola transacción (R2 y R3).
- Una **visita es un grupo**: sus integrantes van en `visitantes` (uno por
  persona, con su edad y procedencia) y sus actividades en
  `visitas.actividades` (una o varias). El `token` de la visita es lo que va
  en el **QR único del grupo** (R9). Visita e integrantes se insertan en una
  sola transacción para que no quede un grupo vacío.
- **RLS activado en todas las tablas.** Catálogo (`espacios`, `rutas`,
  `puntos`, `servicios`, `productos`) con lectura pública; `visitas`,
  `visitantes`, `escaneos` y `canjes` solo para la asociación dueña o el
  titular del token de la visita. Nunca expongas DNI ni edad públicamente.
- **Idiomas:** el esquema guarda el contenido en un solo idioma. Si se
  decide traducir nombres y descripciones, hay que agregar columnas por
  idioma (por ejemplo `nombre_en`) y acordarlo con el proyecto web.

## 4. Repositorios (capa `data`)

Por cada interfaz de `domain/` crea `<x>_repository_supabase.dart`:

1. Implementa la misma interfaz (`EspacioRepository`, `PuntosRepository`,
   `VisitasRepository`).
2. Convierte filas ↔ modelos de dominio en el repositorio (los modelos de
   dominio no conocen Supabase).
3. Cambia solo el Provider en `data/` para devolver la versión Supabase cuando
   la configuración exista.
4. Las interfaces que hoy son síncronas pasarán a devolver `Future`/`Stream`:
   actualiza los ViewModels a `AsyncNotifier` y las pruebas.

## 5. Offline-first y sincronización

- **Base local** (por ejemplo, `drift` o `sqflite`, verificando compatibilidad)
  como fuente de verdad: el repositorio lee de local.
- **Descarga del paquete del espacio** en el puesto de control: espacio, rutas
  (GeoJSON), puntos, servicios, productos e imágenes comprimidas.
- **Cola de pendientes:** escaneos, opiniones y canjes se guardan localmente
  con estado `pendiente`.
- **Sincronización** al detectar conexión: `upsert` por `id` (no duplica al
  reintentar). La respuesta con los ids aceptados se aplica con
  `PasaporteViewModel.confirmar`.
- Prueba todo en **modo avión**.

## 6. Cerrar

- Actualiza `docs/PRODUCTO.md` (estado) y `CLAUDE.md` (sección Estado actual).
- `/verificar-calidad` en verde. Las pruebas no deben necesitar red: usa los
  repositorios demo o dobles de prueba.
