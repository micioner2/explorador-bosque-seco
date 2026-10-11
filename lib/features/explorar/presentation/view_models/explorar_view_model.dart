import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enlaces/abrir_enlace.dart';
import '../../data/espacio_repository_demo.dart';
import '../../domain/espacio.dart';

/// Estado de la pantalla Explorar: el espacio que el turista descargó.
final explorarViewModelProvider = Provider<Espacio>(
  (ref) => ref.watch(espacioRepositoryProvider).espacioActual(),
);

/// Contacta a un socio: abre WhatsApp con [mensaje] ya escrito.
typedef ContactarServicio =
    Future<bool> Function(Servicio servicio, String mensaje);

/// Devuelve `false` si el número del servicio no es válido o el celular no
/// pudo abrir WhatsApp; entonces la pantalla muestra el número.
final contactarServicioProvider = Provider<ContactarServicio>((ref) {
  final abrir = ref.watch(abrirEnlaceProvider);
  return (servicio, mensaje) async {
    final enlace = servicio.enlaceWhatsapp(mensaje);
    return enlace != null && await abrir(enlace);
  };
});
