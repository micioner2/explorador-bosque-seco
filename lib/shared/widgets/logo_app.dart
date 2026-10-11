import 'package:flutter/material.dart';

/// Logo de EcoRumbo. Muestra la versión verde sobre fondo claro y la blanca
/// sobre fondo oscuro, para que se vea bien en los dos temas.
///
/// Es decorativo: no se anuncia en los lectores de pantalla porque la
/// pantalla ya lleva su propio encabezado con el nombre.
class LogoApp extends StatelessWidget {
  const LogoApp({super.key, this.alto = 88});

  /// Alto del logo en píxeles lógicos. El ancho se ajusta solo.
  final double alto;

  @override
  Widget build(BuildContext context) {
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    final ruta = oscuro
        ? 'assets/fotos/logo_blanco.png'
        : 'assets/fotos/logo_verde.png';

    return ExcludeSemantics(
      child: Image.asset(ruta, height: alto, fit: BoxFit.contain),
    );
  }
}
