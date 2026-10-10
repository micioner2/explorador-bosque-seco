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

## Pruebas

- `test/features/*/` prueba el dominio (reglas puras) y los ViewModels con
  `ProviderContainer`, sustituyendo repositorios y reloj por dobles de prueba.
- `test/app_test.dart` prueba la navegación principal con widgets.
