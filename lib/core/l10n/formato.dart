import 'package:intl/intl.dart';

/// Distancia legible: "850 m" o "1,2 km". El separador decimal depende del
/// [idioma] (coma en español, punto en inglés).
String formatearDistancia(int metros, String idioma) {
  if (metros < 1000) return '$metros m';
  return '${NumberFormat('0.#', idioma).format(metros / 1000)} km';
}

/// Fecha completa, con el día de la semana: "Lunes, 12 de octubre" o
/// "Monday, October 12".
String formatearFecha(DateTime fecha, String idioma) {
  final texto = DateFormat.MMMMEEEEd(idioma).format(fecha);
  return texto.substring(0, 1).toUpperCase() + texto.substring(1);
}

/// Fecha corta para botones: "lun, 12 oct" o "Mon, Oct 12".
String formatearFechaCorta(DateTime fecha, String idioma) =>
    DateFormat.MMMEd(idioma).format(fecha);

/// Duración legible: "25 min", "2 h" o "1 h 50 min".
String formatearDuracion(Duration duracion) {
  final horas = duracion.inHours;
  final minutos = duracion.inMinutes.remainder(60);
  if (horas == 0) return '$minutos min';
  if (minutos == 0) return '$horas h';
  return '$horas h $minutos min';
}

/// Hora como la dice la gente: "6:05 p. m." o "6:05 PM".
String formatearHora(DateTime fecha, String idioma) =>
    DateFormat.jm(idioma).format(fecha);
