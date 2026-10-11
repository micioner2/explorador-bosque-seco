import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_espacios.dart';
import '../../../../core/theme/colores_app.dart';
import '../../../../shared/widgets/encabezado.dart';

/// Cabecera marrón de los dos pasos para entrar al puesto de control. Dice
/// en qué paso va la persona ("Paso 1 de 2") para que sepa cuánto falta.
class CabeceraAcceso extends StatelessWidget {
  const CabeceraAcceso({
    super.key,
    required this.paso,
    required this.icono,
    required this.titulo,
    required this.detalle,
  });

  static const pasos = 2;

  final int paso;
  final IconData icono;
  final String titulo;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    final textos = context.textos;
    final frente = context.colores.sobreBarraAsociacion;
    final textoPaso = context.l10n.accesoPaso(paso, pasos);

    return Encabezado(
      deAsociacion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: frente.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icono, size: 26),
                ),
              ),
              const SizedBox(width: AppEspacios.m),
              Expanded(
                child: Text(
                  textoPaso.toUpperCase(),
                  semanticsLabel: textoPaso,
                  style: textos.labelSmall?.copyWith(color: frente),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppEspacios.m),
          Semantics(
            header: true,
            child: Text(
              titulo,
              style: textos.headlineSmall?.copyWith(color: frente),
            ),
          ),
          const SizedBox(height: AppEspacios.s),
          Text(detalle, style: textos.bodyLarge?.copyWith(color: frente)),
        ],
      ),
    );
  }
}
