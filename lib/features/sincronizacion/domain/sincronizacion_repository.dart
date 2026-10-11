import '../../puntos/domain/escaneo.dart';
import '../../reportes/domain/cierre_dia.dart';
import '../../visitas/domain/visita.dart';

/// Por qué no se pudo sincronizar.
enum FalloSincronizacion {
  /// Sin señal o el servidor no respondió a tiempo.
  sinConexion,

  /// El servidor aún no tiene las tablas de la app.
  sinTablas,

  /// El servidor rechazó el envío (permisos o datos).
  rechazado,
}

class SincronizacionFallida implements Exception {
  const SincronizacionFallida(this.fallo, [this.detalle]);

  final FalloSincronizacion fallo;
  final String? detalle;

  @override
  String toString() => 'SincronizacionFallida(${fallo.name}): $detalle';
}

/// Envía al servidor lo registrado en el celular. Cada registro va con su
/// id generado en el celular y se guarda con *upsert*: reenviarlo no lo
/// duplica. Cada método devuelve los ids (o claves) que el servidor
/// aceptó; lanza [SincronizacionFallida] si no se pudo.
abstract interface class SincronizacionRepository {
  /// Grupos con sus integrantes (solo con la cuenta de la asociación).
  Future<Set<String>> enviarVisitas(Iterable<Visita> visitas);

  /// Sellos del pasaporte del turista. Un punto cuenta una vez por visita
  /// (R1): si el servidor ya tenía ese sello, también cuenta como aceptado.
  Future<Set<String>> enviarEscaneos(Iterable<Escaneo> escaneos);

  /// Cierres del día; devuelve las claves `asociación:día` aceptadas.
  Future<Set<String>> enviarCierres(Iterable<CierreDia> cierres);
}
