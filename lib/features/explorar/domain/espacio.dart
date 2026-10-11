/// Tipo de servicio que ofrece la comunidad. Su texto visible se traduce
/// en `core/l10n/etiquetas_dominio.dart`.
enum TipoServicio { guiado, alimentacion, hospedaje, transporte }

/// Punto turístico de una ruta. Cada uno tiene su QR.
class Atractivo {
  const Atractivo({
    required this.id,
    required this.nombre,
    required this.descripcion,
  });

  final String id;
  final String nombre;
  final String descripcion;
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
