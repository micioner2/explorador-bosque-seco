---
name: nueva-funcionalidad
description: Crea una funcionalidad nueva de la app siguiendo la arquitectura MVVM por funcionalidad (domain, data, view_models, views), con su Provider, ruta y pruebas. Úsala cuando pidan agregar una pantalla, un módulo o un caso de uso nuevo (por ejemplo "agrega la pantalla de opinión" o "crea el módulo de canje").
argument-hint: "[nombre-de-la-funcionalidad]"
---

# Crear una funcionalidad: $ARGUMENTS

Sigue estos pasos en orden. Toma como ejemplo completo la funcionalidad
`lib/features/visitas/` y sus pruebas en `test/features/visitas/`.

## 1. Ubicar o crear la carpeta

`lib/features/<nombre>/` con nombre en español, en minúsculas y con guion bajo
si hace falta (`opiniones`, `canjes`). Si la funcionalidad encaja en una que
ya existe (por ejemplo, el canje en `puntos`), agrégala ahí en vez de crear otra.

## 2. Dominio (`domain/`): Dart puro

- Modelos inmutables con validaciones en el constructor (lanza `ArgumentError`
  con un mensaje en español).
- Reglas de negocio como métodos del modelo o clases de cálculo
  (ejemplo: `ResumenDelDia.calcular`).
- Interfaz del repositorio:
  ```dart
  abstract interface class OpinionesRepository {
    List<Opinion> opinionesDe(String visitaId);
  }
  ```
- **Prohibido** importar Flutter, Riverpod o paquetes externos aquí.

## 3. Datos (`data/`)

- Implementación de demostración `<x>_repository_demo.dart` con datos
  realistas. Lo que no se sepa va entre corchetes: `'[tarifa]'`.
- El Provider del repositorio vive en este mismo archivo:
  ```dart
  final opinionesRepositoryProvider = Provider<OpinionesRepository>(
    (ref) => const OpinionesRepositoryDemo(),
  );
  ```

## 4. ViewModel (`presentation/view_models/`)

- Estado de solo lectura: `Provider<T>`.
- Estado con acciones: `Notifier<T>` + `NotifierProvider`.
- La hora siempre con `ref.read(relojProvider)()`.
- Las acciones delegan las reglas al dominio y actualizan `state` con una copia
  nueva.

## 5. Vista (`presentation/views/`)

- `ConsumerWidget` (o `ConsumerStatefulWidget` si tiene formulario).
- Solo `ref.watch(<x>ViewModelProvider)` y llamadas a métodos del ViewModel.
- Colores desde `AppColors`; textos cortos; botones de al menos 48 px.
- Widgets privados (`_Algo`) en el mismo archivo.

## 6. Ruta

- Agrega la constante en `lib/core/router/rutas.dart`.
- Registra la ruta en `lib/core/router/app_router.dart` (dentro del shell que
  corresponda: turista o asociación).

## 7. Pruebas (`test/features/<nombre>/`)

- Una prueba por regla de dominio (casos válidos y de error).
- Prueba del ViewModel con `ProviderContainer`, sustituyendo el repositorio y
  `relojProvider` con `overrideWithValue`.
- Si cambia la navegación, ajusta `test/app_test.dart`.

## 8. Cerrar

1. Actualiza el estado de la funcionalidad en `docs/PRODUCTO.md` (sección 4).
2. Ejecuta `/verificar-calidad` y deja todo en verde.
