---
name: verificar-calidad
description: Ejecuta las mismas validaciones del CI (dart format, flutter analyze y flutter test) y corrige lo que falle. Úsala antes de hacer commit, al terminar un cambio o cuando el CI de GitHub Actions falle.
allowed-tools: Bash(flutter pub get) Bash(flutter gen-l10n) Bash(dart format *) Bash(flutter analyze) Bash(flutter test *) Bash(flutter test)
---

# Verificar calidad como el CI

El workflow `.github/workflows/ci.yml` bloquea si falla cualquiera de estos
pasos. Ejecútalos en este orden y no des el trabajo por terminado hasta que
los tres pasen.

1. **Dependencias:** `flutter pub get`
   - También genera las traducciones (`lib/l10n/app_localizations*.dart`).
     Si editaste un `.arb`, corre además `flutter gen-l10n`.
   - El CI usa `--enforce-lockfile`: si cambiaste `pubspec.yaml`, sube
     también el `pubspec.lock` actualizado.
2. **Formato:** `dart format lib test`
   - Aplica el formato; luego revisa con `git diff` qué cambió.
3. **Análisis:** `flutter analyze`
   - Falla también con observaciones de tipo *info*. Corrígelas, no las
     ignores con `// ignore:` salvo que haya una razón documentada.
   - Errores típicos de este proyecto:
     - `inference_failure_on_function_invocation`: agrega el genérico
       (`context.push<void>(...)`).
     - `prefer_const_constructors`: agrega `const`.
     - `directives_ordering`: ordena los imports (`package:` primero y luego
       relativos, alfabéticamente).
4. **Pruebas:** `flutter test`
   - Si una prueba falla, corrige el código, no la prueba, salvo que la regla
     haya cambiado a propósito (y entonces actualiza `docs/PRODUCTO.md`).
   - `accesibilidad_test.dart` falla por contraste bajo, botones de menos de
     48 px, botones de icono sin `tooltip` o textos que se desbordan con
     letra grande: corrige la pantalla.
   - `traducciones_test.dart` falla si un texto está en un `.arb` y no en el
     otro: agrega la traducción que falta.
   - La prueba con el Supabase real (`test/integracion/`) se omite sin
     configuración. Si tocaste la conexión, córrela aparte con
     `flutter test --tags supabase --dart-define-from-file=config/supabase.json`.

## Si el CI de GitHub falla y en local pasa

- Confirma que usas **Flutter 3.38.9** (`flutter --version`).
- Abre la ejecución en GitHub Actions: el **resumen del job** muestra el diff de
  formato, la salida de `flutter analyze` o las últimas líneas de las pruebas.
- Si falta `pubspec.lock`, genéralo con `flutter pub get` y súbelo.

## Al terminar

Informa en una línea: formato, análisis y pruebas (cuántas pasaron).
