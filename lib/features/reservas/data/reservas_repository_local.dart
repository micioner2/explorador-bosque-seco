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

  /// Reservas con las que empieza el celular la primera vez (datos de
  /// demostración), o `null` para empezar vacío.
  final List<Reserva> Function(DateTime hoy)? semilla;

  final ColeccionLocal<Reserva> _coleccion;
  List<Reserva>? _reservas;

  List<Reserva> _todas(DateTime hoy) {
    final guardadas = _reservas ??= _coleccion.leer();
    if (guardadas != null) return guardadas;
    final iniciales = semilla?.call(hoy) ?? const <Reserva>[];
    _reservas = [...iniciales];
    _coleccion.guardar(iniciales);
    return _reservas!;
  }

  @override
  List<Reserva> reservas(DateTime hoy) {
    final inicioDelDia = DateTime(hoy.year, hoy.month, hoy.day);
    return [
      for (final reserva in _todas(hoy))
        if (reserva.pendiente || !reserva.fechaHora.isBefore(inicioDelDia))
          reserva,
    ];
  }

  @override
  Future<void> guardar(Reserva reserva) {
    final todas = _todas(reserva.fechaHora);
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
/// celular. Sin servidor (cuenta de prueba), empiezan con las de
/// demostración.
final reservasRepositoryProvider = Provider<ReservasRepository>(
  (ref) => ReservasRepositoryLocal(
    ref.watch(almacenLocalProvider),
    semilla: ref.watch(datosDemoProvider)
        ? const ReservasRepositoryDemo().reservas
        : null,
  ),
);
