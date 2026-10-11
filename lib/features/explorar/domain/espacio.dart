/// Tipo de servicio que ofrece la comunidad. Su texto visible se traduce
/// en `core/l10n/etiquetas_dominio.dart`.
enum TipoServicio { guiado, alimentacion, hospedaje, transporte }

/// Punto turístico de una ruta. Cada uno tiene su QR.
class Atractivo {
  const Atractivo({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.foto,
  });

  final String id;
  final String nombre;
  final String descripcion;

  /// Imagen incluida en la app (ruta del asset), para verla sin señal.
  final String? foto;
}

/// Servicio de un socio de la asociación, con contacto directo.
class Servicio {
  const Servicio({
    required this.id,
    required this.tipo,
    required this.nombre,
    required this.whatsapp,
    this.tarifaReferencial,
  });

  final String id;
  final TipoServicio tipo;
  final String nombre;
  final String whatsapp;

  /// Texto libre: hoy no hay tarifas fijas, cada asociación las define.
  final String? tarifaReferencial;

  /// Número de WhatsApp en formato internacional, solo dígitos
  /// (`51987654321`), o `null` si [whatsapp] no es un número válido.
  ///
  /// Los socios escriben su celular como lo dicen ("987 654 321"): un
  /// celular peruano de 9 dígitos que empieza con 9 recibe el prefijo 51.
  String? get numeroWhatsapp {
    final digitos = whatsapp.replaceAll(RegExp(r'\D'), '');
    if (digitos.length == 9 && digitos.startsWith('9')) return '51$digitos';
    if (digitos.length == 11 && digitos.startsWith('519')) return digitos;
    final internacional = whatsapp.trim().startsWith('+');
    if (internacional && digitos.length >= 8 && digitos.length <= 15) {
      return digitos;
    }
    return null;
  }

  /// Enlace que abre WhatsApp con [mensaje] ya escrito, o `null` si el
  /// número no es válido.
  Uri? enlaceWhatsapp(String mensaje) {
    final numero = numeroWhatsapp;
    if (numero == null) return null;
    return Uri.https('wa.me', '/$numero', {'text': mensaje});
  }
}

/// Área natural que administra una asociación (por ejemplo, El Angolo).
class Espacio {
  const Espacio({
    required this.id,
    required this.nombre,
    required this.ubicacion,
    required this.mediosPago,
    required this.senal,
    required this.acceso,
    required this.atractivos,
    required this.servicios,
  });

  final String id;
  final String nombre;
  final String ubicacion;
  final List<String> mediosPago;
  final String senal;
  final String acceso;
  final List<Atractivo> atractivos;
  final List<Servicio> servicios;
}
