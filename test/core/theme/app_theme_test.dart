import 'package:explorador_bosque_seco/core/theme/app_theme.dart';
import 'package:explorador_bosque_seco/core/theme/colores_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contraste entre dos colores según WCAG 2.1 (de 1 a 21).
double contraste(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final (claro, oscuro) = la > lb ? (la, lb) : (lb, la);
  return (claro + 0.05) / (oscuro + 0.05);
}

void main() {
  for (final (nombre, tema) in [
    ('claro', AppTheme.claro),
    ('oscuro', AppTheme.oscuro),
  ]) {
    group('tema $nombre', () {
      final esquema = tema.colorScheme;
      final colores = tema.extension<ColoresApp>()!;

      // Texto sobre su fondo: mínimo AA para texto normal (4,5:1).
      final parejas = <String, (Color, Color)>{
        'botón principal': (esquema.onPrimary, esquema.primary),
        'contenedor primario': (
          esquema.onPrimaryContainer,
          esquema.primaryContainer,
        ),
        'botón de escanear': (esquema.onSecondary, esquema.secondary),
        'texto sobre tarjeta': (esquema.onSurface, esquema.surface),
        'texto secundario sobre tarjeta': (
          esquema.onSurfaceVariant,
          esquema.surface,
        ),
        'texto secundario sobre fondo': (
          esquema.onSurfaceVariant,
          tema.scaffoldBackgroundColor,
        ),
        'texto secundario sobre etiqueta': (
          esquema.onSurfaceVariant,
          esquema.surfaceContainerHighest,
        ),
        'título de sección': (esquema.primary, tema.scaffoldBackgroundColor),
        'alerta': (esquema.onErrorContainer, esquema.errorContainer),
        'error sobre tarjeta': (esquema.error, esquema.surface),
        'cabecera turista': (colores.sobreEncabezado, colores.encabezado),
        'aviso sin señal': (colores.sobreAviso, colores.aviso),
        'barra asociación': (
          colores.sobreBarraAsociacion,
          colores.barraAsociacion,
        ),
      };

      for (final MapEntry(key: uso, value: (frente, fondo))
          in parejas.entries) {
        test('$uso se lee con contraste AA', () {
          expect(contraste(frente, fondo), greaterThanOrEqualTo(4.5));
        });
      }

      // Gráficos sin texto (barras, bordes de campos): mínimo 3:1.
      test('las barras de avance y los bordes se distinguen', () {
        expect(
          contraste(esquema.tertiary, esquema.surface),
          greaterThanOrEqualTo(3),
        );
        expect(
          contraste(esquema.outline, esquema.surface),
          greaterThanOrEqualTo(3),
        );
      });
    });
  }
}
