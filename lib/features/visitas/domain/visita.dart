/// Procedencia del visitante, tal como se agrupa en el reporte diario.
enum Procedencia {
  piura('Piura'),
  lima('Lima'),
  otraRegion('Otra región'),
  extranjero('Extranjero');

  const Procedencia(this.etiqueta);

  final String etiqueta;
}

/// Actividad principal de la visita.
enum Actividad {
  senderismo('Senderismo'),
  aves('Avistamiento de aves'),
  fotografia('Fotografía'),
  campamento('Campamento');

  const Actividad(this.etiqueta);

  final String etiqueta;
}

/// Visita registrada en el puesto de control. Reemplaza al cuaderno.
class Visita {
  Visita({
    required this.id,
    required this.asociacionId,
    required this.nombreResponsable,
    required this.edad,
    required this.procedencia,
    required this.tamanoGrupo,
    required this.actividad,
    required this.fechaEntrada,
    required this.salidaPrevista,
    this.guia,
    this.fechaSalida,
  }) {
    if (nombreResponsable.trim().isEmpty) {
      throw ArgumentError.value(
        nombreResponsable,
        'nombreResponsable',
        'No puede estar vacío',
      );
    }
    if (edad < 0 || edad > 120) {
      throw ArgumentError.value(edad, 'edad', 'Edad fuera de rango');
    }
    if (tamanoGrupo < 1) {
      throw ArgumentError.value(tamanoGrupo, 'tamanoGrupo', 'Mínimo 1');
    }
    if (!salidaPrevista.isAfter(fechaEntrada)) {
      throw ArgumentError.value(
        salidaPrevista,
        'salidaPrevista',
        'Debe ser posterior a la entrada',
      );
    }
  }

  final String id;
  final String asociacionId;
  final String nombreResponsable;
  final int edad;
  final Procedencia procedencia;
  final int tamanoGrupo;
  final Actividad actividad;
  final DateTime fechaEntrada;
  final DateTime salidaPrevista;
  final String? guia;
  final DateTime? fechaSalida;

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
      nombreResponsable: nombreResponsable,
      edad: edad,
      procedencia: procedencia,
      tamanoGrupo: tamanoGrupo,
      actividad: actividad,
      fechaEntrada: fechaEntrada,
      salidaPrevista: salidaPrevista,
      guia: guia,
      fechaSalida: fecha,
    );
  }
}
