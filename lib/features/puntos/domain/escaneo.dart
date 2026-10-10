/// Estado de sincronización de un escaneo de QR.
///
/// En el bosque no hay señal: el escaneo se guarda como [pendiente] en el
/// celular y pasa a [confirmado] cuando el servidor lo acepta.
enum EstadoEscaneo { pendiente, confirmado }

/// Registro de que una visita escaneó el QR de un punto turístico.
class Escaneo {
  const Escaneo({
    required this.id,
    required this.visitaId,
    required this.puntoId,
    required this.fecha,
    this.estado = EstadoEscaneo.pendiente,
  });

  /// Identificador generado en el celular. Permite reenviar el mismo
  /// escaneo varias veces sin duplicarlo en el servidor (idempotencia).
  final String id;
  final String visitaId;
  final String puntoId;
  final DateTime fecha;
  final EstadoEscaneo estado;

  bool get estaConfirmado => estado == EstadoEscaneo.confirmado;

  /// Clave que identifica el par visita-punto. Un mismo punto solo da
  /// puntos una vez por visita.
  String get clave => '$visitaId::$puntoId';

  Escaneo confirmar() => Escaneo(
    id: id,
    visitaId: visitaId,
    puntoId: puntoId,
    fecha: fecha,
    estado: EstadoEscaneo.confirmado,
  );
}
