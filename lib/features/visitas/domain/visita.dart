/// Procedencia del visitante, tal como se agrupa en el reporte diario.
/// Su texto visible se traduce en `core/l10n/etiquetas_dominio.dart`.
enum Procedencia { piura, lima, otraRegion, extranjero }

/// Actividad que el grupo hará en el bosque. Un grupo puede elegir varias.
enum Actividad { senderismo, aves, fotografia, campamento }

/// Persona que ingresa al bosque. En un grupo, cada integrante se registra
/// por separado para que el reporte cuente edades y procedencias reales.
class Visitante {
  Visitante({
    required String nombre,
    required this.edad,
    required this.procedencia,
  }) : nombre = nombre.trim() {
    if (this.nombre.isEmpty) {
      throw ArgumentError.value(nombre, 'nombre', 'No puede estar vacío');
    }
    if (edad < 0 || edad > 120) {
      throw ArgumentError.value(edad, 'edad', 'Edad fuera de rango');
    }
  }

  final String nombre;
  final int edad;
  final Procedencia procedencia;
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
      fechaSalida: fecha,
    );
  }
}
