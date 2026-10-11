/// En qué quedó una reserva.
enum EstadoReserva {
  /// Aún no llegan.
  pendiente,

  /// Se canceló: ya no se espera al grupo.
  cancelada,

  /// El grupo llegó y se registró como visita (ingreso efectivo).
  ingresada,
}

/// Reserva de una visita: quién viene, cuándo y cuántas personas son.
///
/// Cuando el grupo llega, se registra como siempre (cada integrante por
/// separado) y la reserva queda [EstadoReserva.ingresada], ligada a esa
/// visita. Reglas R13 a R15.
class Reserva {
  Reserva({
    required this.id,
    required this.asociacionId,
    required String nombreContacto,
    String? telefono,
    required this.fechaHora,
    required this.personas,
    this.estado = EstadoReserva.pendiente,
    this.reprogramaciones = 0,
    this.visitaId,
    this.guiaId,
    this.nombreGuia,
  }) : nombreContacto = nombreContacto.trim(),
       telefono = (telefono == null || telefono.trim().isEmpty)
           ? null
           : telefono.trim() {
    if (this.nombreContacto.isEmpty) {
      throw ArgumentError.value(
        nombreContacto,
        'nombreContacto',
        'No puede estar vacío',
      );
    }
    _validarPersonas(personas);
  }

  /// Reserva recién anotada. La visita no puede ser para una hora que ya
  /// pasó (R13).
  factory Reserva.nueva({
    required String id,
    required String asociacionId,
    required String nombreContacto,
    String? telefono,
    required DateTime fechaHora,
    required int personas,
    required DateTime ahora,
    String? guiaId,
    String? nombreGuia,
  }) {
    _validarFecha(fechaHora, ahora);
    return Reserva(
      id: id,
      asociacionId: asociacionId,
      nombreContacto: nombreContacto,
      telefono: telefono,
      fechaHora: fechaHora,
      personas: personas,
      guiaId: guiaId,
      nombreGuia: nombreGuia,
    );
  }

  /// Más personas que esto suele ser un error al anotar.
  static const maxPersonas = 99;

  final String id;
  final String asociacionId;

  /// Quien hizo la reserva. Suele ser el responsable del grupo al llegar.
  final String nombreContacto;
  final String? telefono;

  /// Día y hora en que el grupo llega al puesto de control.
  final DateTime fechaHora;

  /// Personas que se esperan. El grupo que llega puede ser distinto: se
  /// registra a quienes vinieron de verdad.
  final int personas;

  final EstadoReserva estado;

  /// Veces que se cambió la fecha o la hora.
  final int reprogramaciones;

  /// Visita en que se convirtió al llegar el grupo.
  final String? visitaId;

  /// Guía que anotó la reserva.
  final String? guiaId;
  final String? nombreGuia;

  bool get pendiente => estado == EstadoReserva.pendiente;

  /// Una fecha sirve para reservar si no pasó. Se compara al minuto, como
  /// se elige en la pantalla.
  static bool fechaValida(DateTime fechaHora, DateTime ahora) =>
      !fechaHora.isBefore(
        DateTime(ahora.year, ahora.month, ahora.day, ahora.hour, ahora.minute),
      );

  bool esDelDia(DateTime dia) =>
      fechaHora.year == dia.year &&
      fechaHora.month == dia.month &&
      fechaHora.day == dia.day;

  /// Ya pasó la hora y el grupo aún no llega.
  bool retrasada(DateTime ahora) => pendiente && ahora.isAfter(fechaHora);

  /// Era para un día anterior y el grupo nunca llegó.
  bool noLlego(DateTime ahora) =>
      pendiente &&
      fechaHora.isBefore(DateTime(ahora.year, ahora.month, ahora.day));

  /// Cambia el día, la hora o las personas. Solo una reserva pendiente, y
  /// nunca a una hora que ya pasó (R14).
  Reserva reprogramar({
    required DateTime fechaHora,
    required int personas,
    required DateTime ahora,
  }) {
    _exigirPendiente('reprogramar');
    _validarFecha(fechaHora, ahora);
    _validarPersonas(personas);
    return _copia(
      fechaHora: fechaHora,
      personas: personas,
      reprogramaciones: reprogramaciones + 1,
    );
  }

  /// Ya no se espera al grupo. Solo una reserva pendiente (R14).
  Reserva cancelar() {
    _exigirPendiente('cancelar');
    return _copia(estado: EstadoReserva.cancelada);
  }

  /// El grupo llegó y quedó registrado como la visita [visitaId]. Una
  /// reserva se convierte en ingreso una sola vez (R15).
  Reserva registrarIngreso(String visitaId) {
    _exigirPendiente('registrar el ingreso de');
    return _copia(estado: EstadoReserva.ingresada, visitaId: visitaId);
  }

  void _exigirPendiente(String accion) {
    if (!pendiente) {
      throw StateError('No se puede $accion la reserva $id: está $estado');
    }
  }

  static void _validarFecha(DateTime fechaHora, DateTime ahora) {
    if (!fechaValida(fechaHora, ahora)) {
      throw ArgumentError.value(fechaHora, 'fechaHora', 'Esa hora ya pasó');
    }
  }

  static void _validarPersonas(int personas) {
    if (personas < 1 || personas > maxPersonas) {
      throw ArgumentError.value(
        personas,
        'personas',
        'Debe ser entre 1 y $maxPersonas',
      );
    }
  }

  Reserva _copia({
    DateTime? fechaHora,
    int? personas,
    EstadoReserva? estado,
    int? reprogramaciones,
    String? visitaId,
  }) => Reserva(
    id: id,
    asociacionId: asociacionId,
    nombreContacto: nombreContacto,
    telefono: telefono,
    fechaHora: fechaHora ?? this.fechaHora,
    personas: personas ?? this.personas,
    estado: estado ?? this.estado,
    reprogramaciones: reprogramaciones ?? this.reprogramaciones,
    visitaId: visitaId ?? this.visitaId,
    guiaId: guiaId,
    nombreGuia: nombreGuia,
  );
}
