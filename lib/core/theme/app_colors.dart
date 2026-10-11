import 'package:flutter/material.dart';

/// Paleta del proyecto, basada en la identidad de AIDER.
///
/// Son los valores "crudos". Las pantallas no los usan directamente: toman
/// los colores del tema (`context.esquema` y `context.colores`), que cambia
/// entre modo claro y oscuro. Ver `app_theme.dart`.
abstract final class AppColors {
  // Identidad.
  static const verdeOscuro = Color(0xFF245237);
  static const verdeInstitucional = Color(0xFF00A550);
  static const amarilloCrema = Color(0xFFFEFAD2);
  static const negroGrisaceo = Color(0xFF201E1E);
  static const marronTierra = Color(0xFF806950);
  static const celesteCielo = Color(0xFF5ECBF5);
  static const blanco = Color(0xFFFFFFFF);

  // Modo claro.
  static const fondo = Color(0xFFFAF8F1);
  static const superficieSuave = Color(0xFFECEEE6);
  static const textoSecundario = Color(0xFF5B6570);
  static const borde = Color(0xFFE3E7DD);
  static const contorno = Color(0xFF7A8378);
  static const verdeSuave = Color(0xFFE6F4EC);
  static const marronOscuro = Color(0xFF5C4A36);
  static const alerta = Color(0xFF8A3A0E);
  static const alertaSuave = Color(0xFFFDEBDD);
  static const mapaClaro = Color(0xFFEEF1E4);

  // Modo oscuro.
  static const nocheFondo = Color(0xFF111814);
  static const nocheSuperficie = Color(0xFF1A241E);
  static const nocheSuperficieAlta = Color(0xFF243028);
  static const nocheEncabezado = Color(0xFF17382A);
  static const nocheBorde = Color(0xFF34423A);
  static const nocheContorno = Color(0xFF8A968C);
  static const nocheTexto = Color(0xFFECEFE8);
  static const nocheTextoSecundario = Color(0xFFB7C0B6);
  static const verdeClaro = Color(0xFF8ED9AC);
  static const verdeProfundo = Color(0xFF0C2E1C);
  static const verdeContenedor = Color(0xFF1E4630);
  static const verdeMenta = Color(0xFFCDEFD9);
  static const verdeBrillante = Color(0xFF3FCF7F);
  static const marronClaro = Color(0xFFD9C4A8);
  static const marronProfundo = Color(0xFF3A2D1D);
  static const marronContenedor = Color(0xFF4A3C2B);
  static const alertaClara = Color(0xFFFFB596);
  static const alertaProfunda = Color(0xFF55200A);
  static const alertaContenedor = Color(0xFF5A2A10);
  static const alertaMelocoton = Color(0xFFFFDBCB);
  static const mapaOscuro = Color(0xFF1C2A22);
}
