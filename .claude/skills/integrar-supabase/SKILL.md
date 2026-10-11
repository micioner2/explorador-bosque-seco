---
name: integrar-supabase
description: Conecta los repositorios de la app a Supabase (Postgres, Auth, Storage) manteniendo el funcionamiento offline-first, cuando el equipo entregue la URL y la clave pública. Úsala al configurar Supabase, crear el esquema, escribir repositorios Supabase o implementar la sincronización. Hoy está PENDIENTE de credenciales.
---

# Integrar Supabase (pendiente de credenciales)

> **Estado:** las credenciales todavía no están. No inventes URL ni claves y no
> dejes la app dependiendo de Supabase hasta tenerlas. Mientras tanto se usan
> los repositorios `*_repository_demo.dart`.

## 1. Configuración (sin subir secretos)

- La URL y la **anon key** van en `config/supabase.json` (ignorado por git),
  copiando `config/supabase.example.json`.
- Se pasan al compilar con `--dart-define-from-file=config/supabase.json` y
  se leen con `String.fromEnvironment('SUPABASE_URL')` y
  `String.fromEnvironment('SUPABASE_ANON_KEY')`.
- Nunca uses la `service_role` key en la app.

## 2. Paquete

- Antes de agregar `supabase_flutter`, verifica en pub.dev que la versión
  soporte **Dart 3.10** (Flutter 3.38.9). Fija la versión con `^x.y.z`.
- Inicializa en `main.dart` solo si las variables existen; si no, la app sigue
  con datos demo.

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
