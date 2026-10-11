import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_espacios.dart';
import '../../../../core/theme/colores_app.dart';
import '../../domain/estado_sincronizacion.dart';

/// Aviso siempre visible con el estado real de la conexión y de lo que
/// falta sincronizar. La pantalla le pasa el [estado] de
/// `estadoPuestoProvider` (grupos y cierre) o de `estadoTuristaProvider`
/// (sellos).
class AvisoConexion extends StatelessWidget {
  const AvisoConexion({required this.estado, super.key});

  final EstadoSincronizacion estado;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final esquema = context.esquema;
    final colores = context.colores;

    // El color nunca va solo: cada estado lleva su icono y su texto.
    final (
      IconData icono,
      String texto,
      Color fondo,
      Color frente,
    ) = switch (estado) {
      SinSenal(:final pendientes) => (
        Icons.wifi_off,
        l10n.conexionSinSenal(pendientes),
        colores.aviso,
        colores.sobreAviso,
      ),
      ConSenal(:final pendientes) => (
        Icons.cloud_upload_outlined,
        l10n.conexionConSenal(pendientes),
        esquema.secondaryContainer,
        esquema.onSecondaryContainer,
      ),
      TodoSincronizado() => (
        Icons.cloud_done_outlined,
        l10n.conexionSincronizado,
        esquema.primaryContainer,
        esquema.onPrimaryContainer,
      ),
    };

    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(AppEspacios.radioChico),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppEspacios.l,
          vertical: AppEspacios.m,
        ),
        child: Row(
          children: [
            ExcludeSemantics(child: Icon(icono, color: frente, size: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                texto,
                style: context.textos.bodyMedium?.copyWith(
                  color: frente,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
