import 'dart:math' as math;

/// Punto en la Tierra (grados decimales, WGS 84, como el GPS).
class Coordenada {
  const Coordenada(this.latitud, this.longitud);

  final double latitud;
  final double longitud;

  static const _radioTierraMetros = 6371000.0;

  /// Distancia en línea recta, en metros (fórmula del haverseno).
  int distanciaA(Coordenada otra) {
    double rad(double grados) => grados * math.pi / 180;
    final dLat = rad(otra.latitud - latitud);
    final dLon = rad(otra.longitud - longitud);
    final a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(rad(latitud)) *
            math.cos(rad(otra.latitud)) *
            math.pow(math.sin(dLon / 2), 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return (_radioTierraMetros * c).round();
  }

  @override
  bool operator ==(Object other) =>
      other is Coordenada &&
      other.latitud == latitud &&
      other.longitud == longitud;

  @override
  int get hashCode => Object.hash(latitud, longitud);
}
