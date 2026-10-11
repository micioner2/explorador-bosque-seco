/// Procedencia del visitante, tal como se agrupa en el reporte diario.
/// Su texto visible se traduce en `core/l10n/etiquetas_dominio.dart`.
enum Procedencia { piura, lima, otraRegion, extranjero }

/// Actividad que el grupo hará en el bosque. Un grupo puede elegir varias.
enum Actividad { senderismo, aves, fotografia, campamento }

/// Qué está mal en el documento de un visitante.
enum ProblemaDocumento {
  /// No se escribió.
  vacio,

  /// Un visitante peruano se identifica con su DNI: 8 dígitos.
  dniInvalido,

  /// Pasaporte o carné de extranjería: de 5 a 15 letras o números.
  documentoInvalido,
}

/// Persona que ingresa al bosque. En un grupo, cada integrante se registra
/// por separado para que el reporte cuente edades y procedencias reales.
///
/// Regla R5 (protocolo del SERNANP para seguridad y rescate): cada persona
/// se identifica con nombre, documento (DNI si es peruana; pasaporte o
/// carné de extranjería si es extranjera), edad y procedencia. Si viene
/// del extranjero, también su país.
class Visitante {
  Visitante({
    required String nombre,
    required String documento,
    required this.edad,
    required this.procedencia,
    String? pais,
  }) : nombre = nombre.trim(),
       documento = normalizarDocumento(documento),
       pais = procedencia == Procedencia.extranjero ? pais?.trim() : null {
    if (this.nombre.isEmpty) {
      throw ArgumentError.value(nombre, 'nombre', 'No puede estar vacío');
    }
    final problema = revisarDocumento(documento, procedencia);
    if (problema != null) {
      throw ArgumentError.value(documento, 'documento', problema.name);
    }
    if (edad < 0 || edad > 120) {
      throw ArgumentError.value(edad, 'edad', 'Edad fuera de rango');
    }
    if (procedencia == Procedencia.extranjero && (this.pais ?? '').isEmpty) {
      throw ArgumentError.value(pais, 'pais', 'Falta el país');
    }
  }

  final String nombre;

  /// DNI, pasaporte o carné de extranjería, sin espacios ni guiones.
  final String documento;
  final int edad;
  final Procedencia procedencia;

  /// País de quien viene del extranjero; `null` para visitantes peruanos.
  final String? pais;

  /// Quita espacios, puntos y guiones, y pasa a mayúsculas.
  static String normalizarDocumento(String documento) =>
      documento.replaceAll(RegExp(r'[\s.\-]'), '').toUpperCase();

  /// `null` si [documento] sirve para alguien de [procedencia].
  static ProblemaDocumento? revisarDocumento(
    String documento,
    Procedencia procedencia,
  ) {
    final limpio = normalizarDocumento(documento);
    if (limpio.isEmpty) return ProblemaDocumento.vacio;
    if (procedencia != Procedencia.extranjero) {
      return RegExp(r'^\d{8}$').hasMatch(limpio)
          ? null
          : ProblemaDocumento.dniInvalido;
    }
    return RegExp(r'^[A-Z0-9]{5,15}$').hasMatch(limpio)
        ? null
        : ProblemaDocumento.documentoInvalido;
  }
}

/// Visita registrada en el puesto de control: una persona o un grupo que
/// entra junto y hace las mismas actividades. Reemplaza al cuaderno.
///
/// Todo el grupo comparte un solo QR ([codigoQr]). Si alguien hará otras
/// actividades, se registra como otra visita.
class Visita {
  Visita({
    required this.id,
    required this.asociacionId,
    required Iterable<Visitante> integrantes,
    required Iterable<Actividad> actividades,
    required this.fechaEntrada,
    required this.salidaPrevista,
    this.guiaId,
    this.nombreGuia,
    this.reservaId,
    this.fechaSalida,
  }) : integrantes = List.unmodifiable(integrantes),
       actividades = Set.unmodifiable(actividades) {
    if (this.integrantes.isEmpty) {
      throw ArgumentError.value(
        integrantes,
        'integrantes',
        'Mínimo un integrante',
      );
    }
    if (this.actividades.isEmpty) {
      throw ArgumentError.value(
        actividades,
        'actividades',
        'Mínimo una actividad',
      );
    }
    if (!salidaPrevista.isAfter(fechaEntrada)) {
      throw ArgumentError.value(
        salidaPrevista,
        'salidaPrevista',
        'Debe ser posterior a la entrada',
      );
    }
  }

  /// Tiempo en el bosque cuando el guía no elige otra salida: un día de
  /// caminata.
  static const duracionPorDefecto = Duration(hours: 8);

  final String id;
  final String asociacionId;

  /// Personas del grupo. La primera es la responsable.
  final List<Visitante> integrantes;

  /// Actividades que hará todo el grupo (una o varias).
  final Set<Actividad> actividades;

  final DateTime fechaEntrada;
  final DateTime salidaPrevista;

  /// Guía que registró al grupo y lo acompaña. Con la asociación, permite
  /// saber quién hizo cada registro.
  final String? guiaId;
  final String? nombreGuia;

  /// Reserva con la que llegó el grupo, si tenía una.
  final String? reservaId;

  final DateTime? fechaSalida;

  Visitante get responsable => integrantes.first;

  String get nombreResponsable => responsable.nombre;

  int get tamanoGrupo => integrantes.length;

  /// Contenido del QR único del grupo. Cada integrante lo escanea con la
  /// app para vincular su celular a esta visita.
  String get codigoQr => 'bosqueseco:visita:$id';

  bool get salio => fechaSalida != null;

  /// El grupo sigue en el bosque después de su hora de salida.
  /// La asociación debe recibir una alerta.
  bool sigueDentro(DateTime ahora) => !salio && ahora.isAfter(salidaPrevista);

  Visita marcarSalida(DateTime fecha) {
    if (salio) {
      throw StateError('La visita $id ya registró su salida');
    }
    if (fecha.isBefore(fechaEntrada)) {
      throw ArgumentError.value(fecha, 'fecha', 'Anterior a la entrada');
    }
    return Visita(
      id: id,
      asociacionId: asociacionId,
      integrantes: integrantes,
      actividades: actividades,
      fechaEntrada: fechaEntrada,
      salidaPrevista: salidaPrevista,
      guiaId: guiaId,
      nombreGuia: nombreGuia,
      reservaId: reservaId,
      fechaSalida: fecha,
    );
  }
}
