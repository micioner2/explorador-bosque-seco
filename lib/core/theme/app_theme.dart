import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_espacios.dart';
import 'colores_app.dart';

/// Tema visual de la app, en modo claro y oscuro. Botones grandes y alto
/// contraste: se usa al aire libre, con sol y en celulares de gama media.
///
/// Todas las parejas texto/fondo cumplen WCAG AA (4,5:1); lo comprueba
/// `test/core/theme/app_theme_test.dart`.
abstract final class AppTheme {
  static final ThemeData claro = _construir(_esquemaClaro, ColoresApp.claro);

  static final ThemeData oscuro = _construir(_esquemaOscuro, ColoresApp.oscuro);

  static final _esquemaClaro =
      ColorScheme.fromSeed(seedColor: AppColors.verdeOscuro).copyWith(
        primary: AppColors.verdeOscuro,
        onPrimary: AppColors.blanco,
        primaryContainer: AppColors.verdeSuave,
        onPrimaryContainer: AppColors.verdeOscuro,
        secondary: AppColors.marronTierra,
        onSecondary: AppColors.blanco,
        secondaryContainer: AppColors.verdeSuave,
        onSecondaryContainer: AppColors.verdeOscuro,
        tertiary: AppColors.verdeInstitucional,
        onTertiary: AppColors.negroGrisaceo,
        error: AppColors.alerta,
        onError: AppColors.blanco,
        errorContainer: AppColors.alertaSuave,
        onErrorContainer: AppColors.alerta,
        surface: AppColors.blanco,
        onSurface: AppColors.negroGrisaceo,
        onSurfaceVariant: AppColors.textoSecundario,
        surfaceContainerHighest: AppColors.superficieSuave,
        outline: AppColors.contorno,
        outlineVariant: AppColors.borde,
      );

  static final _esquemaOscuro =
      ColorScheme.fromSeed(
        seedColor: AppColors.verdeOscuro,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppColors.verdeClaro,
        onPrimary: AppColors.verdeProfundo,
        primaryContainer: AppColors.verdeContenedor,
        onPrimaryContainer: AppColors.verdeMenta,
        secondary: AppColors.marronClaro,
        onSecondary: AppColors.marronProfundo,
        secondaryContainer: AppColors.verdeContenedor,
        onSecondaryContainer: AppColors.verdeMenta,
        tertiary: AppColors.verdeBrillante,
        onTertiary: AppColors.verdeProfundo,
        error: AppColors.alertaClara,
        onError: AppColors.alertaProfunda,
        errorContainer: AppColors.alertaContenedor,
        onErrorContainer: AppColors.alertaMelocoton,
        surface: AppColors.nocheSuperficie,
        onSurface: AppColors.nocheTexto,
        onSurfaceVariant: AppColors.nocheTextoSecundario,
        surfaceContainerHighest: AppColors.nocheSuperficieAlta,
        outline: AppColors.nocheContorno,
        outlineVariant: AppColors.nocheBorde,
      );

  /// Pesos y tamaños propios; lo demás lo pone la tipografía de Material 3.
  static const _textos = TextTheme(
    headlineMedium: TextStyle(fontWeight: FontWeight.w700),
    headlineSmall: TextStyle(fontWeight: FontWeight.w700),
    titleLarge: TextStyle(fontWeight: FontWeight.w700),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    bodyLarge: TextStyle(fontSize: 16, height: 1.4),
    bodyMedium: TextStyle(fontSize: 15, height: 1.4),
    bodySmall: TextStyle(fontSize: 13, height: 1.35),
    labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
    ),
  );

  static ThemeData _construir(ColorScheme esquema, ColoresApp colores) {
    final esOscuro = esquema.brightness == Brightness.dark;
    final tipografia = Typography.material2021(
      platform: defaultTargetPlatform,
      colorScheme: esquema,
    );
    final textoBoton = (esOscuro ? tipografia.white : tipografia.black)
        .labelLarge!
        .copyWith(fontSize: 16, fontWeight: FontWeight.w700);

    final forma = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppEspacios.radioChico),
    );
    final bordeCampo = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppEspacios.radioChico),
      borderSide: BorderSide(color: esquema.outline),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      extensions: [colores],
      scaffoldBackgroundColor: esOscuro
          ? AppColors.nocheFondo
          : AppColors.fondo,
      textTheme: _textos,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: colores.encabezado,
        foregroundColor: colores.sobreEncabezado,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: esquema.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: esquema.shadow,
        elevation: 3,
        indicatorColor: esquema.secondaryContainer,
        iconTheme: WidgetStateProperty.resolveWith(
          (estados) => IconThemeData(
            color: estados.contains(WidgetState.selected)
                ? esquema.onSecondaryContainer
                : esquema.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((estados) {
          final seleccionado = estados.contains(WidgetState.selected);
          return textoBoton.copyWith(
            fontSize: 13,
            fontWeight: seleccionado ? FontWeight.w700 : FontWeight.w500,
            color: seleccionado ? esquema.onSurface : esquema.onSurfaceVariant,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: forma,
          textStyle: textoBoton,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: esquema.primary,
          minimumSize: const Size(64, AppEspacios.objetivoTactil),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: forma,
          side: BorderSide(color: esquema.primary, width: 1.5),
          textStyle: textoBoton.copyWith(fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(
            AppEspacios.objetivoTactil,
            AppEspacios.objetivoTactil,
          ),
          textStyle: textoBoton.copyWith(fontSize: 15),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: esquema.secondary,
        foregroundColor: esquema.onSecondary,
        extendedTextStyle: textoBoton,
      ),
      cardTheme: CardThemeData(
        color: esquema.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppEspacios.radio),
          side: BorderSide(color: esquema.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: esquema.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppEspacios.l,
          vertical: AppEspacios.l,
        ),
        border: bordeCampo,
        enabledBorder: bordeCampo,
        focusedBorder: bordeCampo.copyWith(
          borderSide: BorderSide(color: esquema.primary, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: esquema.surface,
        selectedColor: esquema.secondaryContainer,
        checkmarkColor: esquema.onSecondaryContainer,
        side: BorderSide(color: esquema.outline),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: esquema.onSurfaceVariant,
        selectedColor: esquema.primary,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: esquema.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppEspacios.xl),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: forma,
      ),
      dividerTheme: DividerThemeData(
        color: esquema.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: esquema.tertiary,
        linearTrackColor: esquema.surfaceContainerHighest,
      ),
    );
  }
}
