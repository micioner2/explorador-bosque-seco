import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Abre un enlace fuera de la app (WhatsApp, el navegador). Devuelve
/// `false` si el celular no tiene con qué abrirlo.
typedef AbrirEnlace = Future<bool> Function(Uri enlace);

/// Las pruebas lo sustituyen para no salir de la app.
final abrirEnlaceProvider = Provider<AbrirEnlace>((ref) => _abrirFuera);

Future<bool> _abrirFuera(Uri enlace) async {
  try {
    return await launchUrl(enlace, mode: LaunchMode.externalApplication);
  } on Exception catch (error) {
    debugPrint('No se pudo abrir $enlace: $error');
    return false;
  }
}
