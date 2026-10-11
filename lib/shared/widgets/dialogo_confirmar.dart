import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';

/// Pide confirmación antes de una acción que no se puede deshacer (canjear
/// puntos, marcar una salida). Devuelve `true` solo si la persona acepta.
Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String detalle,
  required String accion,
}) async {
  final respuesta = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo),
      content: Text(detalle),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.cancelar),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(accion),
        ),
      ],
    ),
  );
  return respuesta ?? false;
}
