import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/almacen/almacen_local.dart';
import '../../../core/almacen/coleccion_local.dart';
import '../domain/reserva.dart';
import '../domain/reservas_repository.dart';
import 'reservas_repository_demo.dart';

/// Reservas guardadas en el celular. Funciona en modo avión; cada reserva
/// lleva su id generado en el celular.
class ReservasRepositoryLocal implements ReservasRepository {
  ReservasRepositoryLocal(AlmacenLocal almacen, {this.semilla})
    : _coleccion = ColeccionLocal(
        almacen,
        'reservas',
        aJson: reservaAJson,
        deJson: reservaDeJson,
      );

  /// Reservas de demostración a partir de la hora actual, o `null` para no
  /// tener ninguna. No se guardan: se calculan cada vez. Si el guía cambia
  /// una (la cancela o llega el grupo), se guarda esa versión y reemplaza a
  /// la de demostración.
  final List<Reserva> Function(DateTime ahora)? semilla;

  final ColeccionLocal<Reserva> _coleccion;
  List<Reserva>? _guardadas;

  List<Reserva> get _todas => _guardadas ??= _coleccion.leer() ?? [];

  @override
  List<Reserva> reservas(DateTime hoy) {
    final inicioDelDia = DateTime(hoy.year, hoy.month, hoy.day);
    final guardadas = _todas;
    final ids = {for (final r in guardadas) r.id};
    return [
      for (final reserva in [
        ...?semilla?.call(hoy).where((r) => !ids.contains(r.id)),
        ...guardadas,
      ])
        if (reserva.pendiente || !reserva.fechaHora.isBefore(inicioDelDia))
          reserva,
    ];
  }

  @override
  Future<void> guardar(Reserva reserva) {
    final todas = _todas;
    final indice = todas.indexWhere((r) => r.id == reserva.id);
    if (indice < 0) {
      todas.add(reserva);
    } else {
      todas[indice] = reserva;
    }
    return _coleccion.guardar(todas);
  }
}

Map<String, Object?> reservaAJson(Reserva reserva) => {
  'id': reserva.id,
  'asociacionId': reserva.asociacionId,
  'nombreContacto': reserva.nombreContacto,
  'telefono': reserva.telefono,
  'fechaHora': fechaAJson(reserva.fechaHora),
  'personas': reserva.personas,
  'estado': reserva.estado.name,
  'reprogramaciones': reserva.reprogramaciones,
  'visitaId': reserva.visitaId,
  'guiaId': reserva.guiaId,
  'nombreGuia': reserva.nombreGuia,
};

Reserva reservaDeJson(Map<String, Object?> json) => Reserva(
  id: json['id']! as String,
  asociacionId: json['asociacionId']! as String,
  nombreContacto: json['nombreContacto']! as String,
  telefono: json['telefono'] as String?,
  fechaHora: fechaDeJson(json['fechaHora']),
  personas: json['personas']! as int,
  estado: EstadoReserva.values.byName(json['estado']! as String),
  reprogramaciones: json['reprogramaciones']! as int,
  visitaId: json['visitaId'] as String?,
  guiaId: json['guiaId'] as String?,
  nombreGuia: json['nombreGuia'] as String?,
);

/// Punto único donde se elige la implementación: las reservas viven en el
/// celular. Sin servidor (cuenta de prueba), se suman las de demostración.
final reservasRepositoryProvider = Provider<ReservasRepository>(
  (ref) => ReservasRepositoryLocal(
    ref.watch(almacenLocalProvider),
    semilla: ref.watch(datosDemoProvider)
        ? const ReservasRepositoryDemo().reservasDe
        : null,
  ),
);
