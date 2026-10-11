import 'package:flutter/material.dart';

import '../../core/theme/colores_app.dart';

/// Intención de una [EtiquetaEstado]. El color nunca va solo: siempre lo
/// acompaña un texto (y, si ayuda, un icono).
enum TonoEtiqueta {
  /// Información sin urgencia.
  neutro,

  /// Hecho o confirmado.
  exito,

  /// Sin señal o pendiente de sincronizar.
  aviso,

  /// Lo que sigue o lo más importante.
  acento,
}

/// Etiqueta corta en forma de pastilla: "Visitado", "+1 punto", "-10%".
class EtiquetaEstado extends StatelessWidget {
  const EtiquetaEstado({
    super.key,
    required this.texto,
    this.icono,
    this.tono = TonoEtiqueta.neutro,
  });

  final String texto;
  final IconData? icono;
  final TonoEtiqueta tono;

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquema;
    final colores = context.colores;
    final icono = this.icono;
    final (fondo, frente) = switch (tono) {
      TonoEtiqueta.neutro => (
        esquema.surfaceContainerHighest,
        esquema.onSurfaceVariant,
      ),
      TonoEtiqueta.exito => (
        esquema.primaryContainer,
        esquema.onPrimaryContainer,
      ),
      TonoEtiqueta.aviso => (colores.aviso, colores.sobreAviso),
      TonoEtiqueta.acento => (esquema.primary, esquema.onPrimary),
    };

    return Container(
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icono != null) ...[
            Icon(icono, size: 14, color: frente),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              texto,
              style: context.textos.labelMedium?.copyWith(color: frente),
            ),
          ),
        ],
      ),
    );
  }
}
