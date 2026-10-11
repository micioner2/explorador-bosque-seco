import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_espacios.dart';
import '../../core/theme/colores_app.dart';

/// Aviso que recuerda al turista que su información está guardada en el
/// celular y que funciona sin señal.
class AvisoSinSenal extends StatelessWidget {
  const AvisoSinSenal({super.key, this.mensaje});

  /// Texto del aviso. Si no se indica, se usa el mensaje general.
  final String? mensaje;

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colores.aviso,
        borderRadius: BorderRadius.circular(AppEspacios.radioChico),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppEspacios.l,
        vertical: AppEspacios.m,
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off, color: colores.sobreAviso, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje ?? context.l10n.avisoSinSenal,
              style: context.textos.bodyMedium?.copyWith(
                color: colores.sobreAviso,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
