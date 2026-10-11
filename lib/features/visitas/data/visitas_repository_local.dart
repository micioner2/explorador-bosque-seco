import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/almacen/almacen_local.dart';
import '../../../core/almacen/coleccion_local.dart';
import '../domain/visita.dart';
import '../domain/visitas_repository.dart';
import 'visitas_repository_demo.dart';

/// Visitas guardadas en el celular (reemplazan al cuaderno). Funciona en
/// modo avión; cada visita lleva su id generado en el celular para
/// sincronizarla después sin duplicarla.
class VisitasRepositoryLocal implements VisitasRepository {
  VisitasRepositoryLocal(AlmacenLocal almacen, {this.semilla})
    : _coleccion = ColeccionLocal(
        almacen,
        'visitas',
        aJson: visitaAJson,
        deJson: visitaDeJson,
      );

  /// Visitas con las que empieza el celular la primera vez (datos de
  /// demostración), o `null` para empezar vacío.
  final List<Visita> Function(DateTime dia)? semilla;

  final ColeccionLocal<Visita> _coleccion;
  List<Visita>? _visitas;

  List<Visita> _todas(DateTime hoy) {
    final guardadas = _visitas ??= _coleccion.leer();
    if (guardadas != null) return guardadas;
    final iniciales = semilla?.call(hoy) ?? const <Visita>[];
    _visitas = [...iniciales];
    _coleccion.guardar(iniciales);
    return _visitas!;
  }

  @override
  List<Visita> visitasDelDia(DateTime dia) => [
    for (final visita in _todas(dia))
      if (_mismoDia(visita.fechaEntrada, dia)) visita,
  ];

  @override
  Future<void> guardar(Visita visita) {
    final todas = _todas(visita.fechaEntrada);
    final indice = todas.indexWhere((v) => v.id == visita.id);
    if (indice < 0) {
      todas.add(visita);
    } else {
      todas[indice] = visita;
    }
    return _coleccion.guardar(todas);
  }

  static bool _mismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

Map<String, Object?> visitaAJson(Visita visita) => {
  'id': visita.id,
  'asociacionId': visita.asociacionId,
  'integrantes': [
    for (final persona in visita.integrantes)
      {
        'nombre': persona.nombre,
        'documento': persona.documento,
        'edad': persona.edad,
        'procedencia': persona.procedencia.name,
        'pais': persona.pais,
      },
  ],
  'actividades': [for (final actividad in visita.actividades) actividad.name],
  'fechaEntrada': fechaAJson(visita.fechaEntrada),
  'salidaPrevista': fechaAJson(visita.salidaPrevista),
  'guiaId': visita.guiaId,
  'nombreGuia': visita.nombreGuia,
  'reservaId': visita.reservaId,
  'fechaSalida': visita.fechaSalida == null
      ? null
      : fechaAJson(visita.fechaSalida!),
};

Visita visitaDeJson(Map<String, Object?> json) => Visita(
  id: json['id']! as String,
  asociacionId: json['asociacionId']! as String,
  integrantes: [
    for (final persona in json['integrantes']! as List<Object?>)
      _visitanteDeJson(persona! as Map<String, Object?>),
  ],
  actividades: [
    for (final nombre in json['actividades']! as List<Object?>)
      Actividad.values.byName(nombre! as String),
  ],
  fechaEntrada: fechaDeJson(json['fechaEntrada']),
  salidaPrevista: fechaDeJson(json['salidaPrevista']),
  guiaId: json['guiaId'] as String?,
  nombreGuia: json['nombreGuia'] as String?,
  reservaId: json['reservaId'] as String?,
  fechaSalida: fechaODeJson(json['fechaSalida']),
);

Visitante _visitanteDeJson(Map<String, Object?> json) => Visitante(
  nombre: json['nombre']! as String,
  documento: json['documento']! as String,
  edad: json['edad']! as int,
  procedencia: Procedencia.values.byName(json['procedencia']! as String),
  pais: json['pais'] as String?,
);

/// Punto único donde se elige la implementación: las visitas viven en el
/// celular. Sin servidor (cuenta de prueba), empiezan con las de
/// demostración.
final visitasRepositoryProvider = Provider<VisitasRepository>(
  (ref) => VisitasRepositoryLocal(
    ref.watch(almacenLocalProvider),
    semilla: ref.watch(datosDemoProvider)
        ? const VisitasRepositoryDemo().visitasDelDia
        : null,
  ),
);
