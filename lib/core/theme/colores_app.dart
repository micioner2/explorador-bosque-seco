import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Colores propios de la app que no existen en el `ColorScheme` de Material.
/// Cada uno tiene su versión clara y oscura.
@immutable
class ColoresApp extends ThemeExtension<ColoresApp> {
  const ColoresApp({
    required this.encabezado,
    required this.sobreEncabezado,
    required this.aviso,
    required this.sobreAviso,
    required this.barraAsociacion,
    required this.sobreBarraAsociacion,
    required this.mapa,
  });

  static const claro = ColoresApp(
    encabezado: AppColors.verdeOscuro,
    sobreEncabezado: AppColors.blanco,
    aviso: AppColors.amarilloCrema,
    sobreAviso: AppColors.marronOscuro,
    barraAsociacion: AppColors.marronTierra,
    sobreBarraAsociacion: AppColors.blanco,
    mapa: AppColors.mapaClaro,
  );

  static const oscuro = ColoresApp(
    encabezado: AppColors.nocheEncabezado,
    sobreEncabezado: AppColors.nocheTexto,
    aviso: AppColors.marronContenedor,
    sobreAviso: AppColors.amarilloCrema,
    barraAsociacion: AppColors.marronContenedor,
    sobreBarraAsociacion: AppColors.amarilloCrema,
    mapa: AppColors.mapaOscuro,
  );

  /// Barra superior y cabecera del modo turista.
  final Color encabezado;
  final Color sobreEncabezado;

  /// Avisos de "sin señal" y de datos pendientes de sincronizar.
  final Color aviso;
  final Color sobreAviso;

  /// Barra superior del modo asociación: se distingue del modo turista.
  final Color barraAsociacion;
  final Color sobreBarraAsociacion;

  /// Fondo del esquema de la ruta.
  final Color mapa;

  @override
  ColoresApp copyWith({
    Color? encabezado,
    Color? sobreEncabezado,
    Color? aviso,
    Color? sobreAviso,
    Color? barraAsociacion,
    Color? sobreBarraAsociacion,
    Color? mapa,
  }) => ColoresApp(
    encabezado: encabezado ?? this.encabezado,
    sobreEncabezado: sobreEncabezado ?? this.sobreEncabezado,
    aviso: aviso ?? this.aviso,
    sobreAviso: sobreAviso ?? this.sobreAviso,
    barraAsociacion: barraAsociacion ?? this.barraAsociacion,
    sobreBarraAsociacion: sobreBarraAsociacion ?? this.sobreBarraAsociacion,
    mapa: mapa ?? this.mapa,
  );

  @override
  ColoresApp lerp(ColoresApp? other, double t) {
    if (other == null) return this;
    return ColoresApp(
      encabezado: Color.lerp(encabezado, other.encabezado, t)!,
      sobreEncabezado: Color.lerp(sobreEncabezado, other.sobreEncabezado, t)!,
      aviso: Color.lerp(aviso, other.aviso, t)!,
      sobreAviso: Color.lerp(sobreAviso, other.sobreAviso, t)!,
      barraAsociacion: Color.lerp(barraAsociacion, other.barraAsociacion, t)!,
      sobreBarraAsociacion: Color.lerp(
        sobreBarraAsociacion,
        other.sobreBarraAsociacion,
        t,
      )!,
      mapa: Color.lerp(mapa, other.mapa, t)!,
    );
  }
}

/// Atajos para leer el tema desde una pantalla.
extension ContextoTema on BuildContext {
  ColorScheme get esquema => Theme.of(this).colorScheme;

  ColoresApp get colores => Theme.of(this).extension<ColoresApp>()!;

  TextTheme get textos => Theme.of(this).textTheme;
}
