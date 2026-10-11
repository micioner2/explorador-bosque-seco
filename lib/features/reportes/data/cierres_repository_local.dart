import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/almacen/almacen_local.dart';
import '../../../core/almacen/coleccion_local.dart';
import '../domain/cierre_dia.dart';
import '../domain/cierres_repository.dart';
import '../domain/reporte_diario.dart';

/// Cierres guardados en el celular, uno por día y asociación. Quedan
/// pendientes de sincronizar con el panel de AIDER.
class CierresRepositoryLocal implements CierresRepository {
  CierresRepositoryLocal(AlmacenLocal almacen)
    : _coleccion = ColeccionLocal(
        almacen,
        'cierres',
        aJson: cierreAJson,
        deJson: cierreDeJson,
      );

  final ColeccionLocal<CierreDia> _coleccion;
  List<CierreDia>? _cierres;

  List<CierreDia> get _todos => _cierres ??= _coleccion.leer() ?? [];

  static bool _mismo(CierreDia c, DateTime dia, String asociacionId) =>
      c.asociacionId == asociacionId &&
      c.dia.year == dia.year &&
      c.dia.month == dia.month &&
      c.dia.day == dia.day;

  @override
  CierreDia? cierreDe(DateTime dia, String asociacionId) =>
      _todos.where((c) => _mismo(c, dia, asociacionId)).firstOrNull;

  @override
  Future<void> guardar(CierreDia cierre) {
    final todos = _todos
      ..removeWhere((c) => _mismo(c, cierre.dia, cierre.asociacionId))
      ..add(cierre);
    return _coleccion.guardar(todos);
  }
}

Map<String, Object?> cierreAJson(CierreDia cierre) => {
  'dia': fechaAJson(cierre.dia),
  'asociacionId': cierre.asociacionId,
  'cerradoEn': fechaAJson(cierre.cerradoEn),
  'cerradoPor': cierre.cerradoPor,
  'totalGrupos': cierre.totalGrupos,
  'totalVisitantes': cierre.totalVisitantes,
  'gruposSinSalida': cierre.gruposSinSalida,
  'porGuia': [
    for (final guia in cierre.porGuia)
      {
        'nombreGuia': guia.nombreGuia,
        'grupos': guia.grupos,
        'personas': guia.personas,
      },
  ],
};

CierreDia cierreDeJson(Map<String, Object?> json) => CierreDia(
  dia: fechaDeJson(json['dia']),
  asociacionId: json['asociacionId']! as String,
  cerradoEn: fechaDeJson(json['cerradoEn']),
  cerradoPor: json['cerradoPor']! as String,
  totalGrupos: json['totalGrupos']! as int,
  totalVisitantes: json['totalVisitantes']! as int,
  gruposSinSalida: json['gruposSinSalida']! as int,
  porGuia: [
    for (final guia in json['porGuia']! as List<Object?>)
      if (guia case final Map<String, Object?> g)
        ResumenGuia(
          nombreGuia: g['nombreGuia']! as String,
          grupos: g['grupos']! as int,
          personas: g['personas']! as int,
        ),
  ],
);

final cierresRepositoryProvider = Provider<CierresRepository>(
  (ref) => CierresRepositoryLocal(ref.watch(almacenLocalProvider)),
);
