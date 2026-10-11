import 'package:intl/intl.dart';

/// Distancia legible: "850 m" o "1,2 km". El separador decimal depende del
/// [idioma] (coma en español, punto en inglés).
String formatearDistancia(int metros, String idioma) {
  if (metros < 1000) return '$metros m';
  return '${NumberFormat('0.#', idioma).format(metros / 1000)} km';
}

/// Duración legible: "25 min", "2 h" o "1 h 50 min".
String formatearDuracion(Duration duracion) {
  final horas = duracion.inHours;
  final minutos = duracion.inMinutes.remainder(60);
  if (horas == 0) return '$minutos min';
  if (minutos == 0) return '$horas h';
  return '$horas h $minutos min';
}
