import 'package:flutter/material.dart';

import '../../../../core/l10n/formato.dart';
import '../../../../core/l10n/l10n.dart';

/// "Hoy", "Mañana" o la fecha completa ("Lunes, 12 de octubre").
String textoDia(BuildContext context, DateTime dia, DateTime hoy) {
  final l10n = context.l10n;
  if (DateUtils.isSameDay(dia, hoy)) return l10n.diaHoy;
  if (DateUtils.isSameDay(dia, DateUtils.addDaysToDate(hoy, 1))) {
    return l10n.diaManana;
  }
  return formatearFecha(dia, l10n.localeName);
}

/// Hora en el formato del idioma: "15:00" o "3:00 PM".
String textoHora(BuildContext context, DateTime fechaHora) =>
    TimeOfDay.fromDateTime(fechaHora).format(context);

/// Día y hora de una reserva: "Mañana, 08:00".
String textoCuando(BuildContext context, DateTime fechaHora, DateTime hoy) =>
    context.l10n.reservaCuando(
      textoDia(context, fechaHora, hoy),
      textoHora(context, fechaHora),
    );
