import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tema visual de la app. Botones grandes y alto contraste: se usa al aire
/// libre, con sol y en celulares de gama media.
abstract final class AppTheme {
  static ThemeData get claro {
    final esquema = ColorScheme.fromSeed(
      seedColor: AppColors.verdeOscuro,
      primary: AppColors.verdeOscuro,
      secondary: AppColors.marronTierra,
      tertiary: AppColors.celesteCielo,
      error: AppColors.alerta,
      surface: Colors.white,
    );

    final bordeRedondeado = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: AppColors.fondo,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.verdeOscuro,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.verdeInstitucional,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 52),
          shape: bordeRedondeado,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.verdeOscuro,
          minimumSize: const Size(48, 48),
          shape: bordeRedondeado,
          side: const BorderSide(color: AppColors.verdeOscuro, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.borde),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.marronTierra,
        foregroundColor: Colors.white,
      ),
    );
  }
}
