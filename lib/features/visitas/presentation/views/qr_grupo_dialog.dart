import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/l10n/etiquetas_dominio.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_espacios.dart';
import '../../../../core/theme/colores_app.dart';
import '../../domain/visita.dart';

/// Actividades del grupo en el idioma de la app, en el orden de siempre.
String textoActividades(Visita visita, AppLocalizations l10n) => [
  for (final actividad in Actividad.values)
    if (visita.actividades.contains(actividad)) actividad.texto(l10n),
].join(', ');

/// Muestra el QR único del grupo para que cada integrante lo escanee.
Future<void> mostrarQrGrupo(BuildContext context, Visita visita) =>
    showDialog<void>(
      context: context,
      builder: (context) => _QrGrupoDialog(visita: visita),
    );

class _QrGrupoDialog extends StatelessWidget {
  const _QrGrupoDialog({required this.visita});

  final Visita visita;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final esquema = context.esquema;
    final textos = context.textos;

    return Dialog(
      insetPadding: const EdgeInsets.all(AppEspacios.xl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppEspacios.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.qrTitulo,
                  textAlign: TextAlign.center,
                  style: textos.titleLarge,
                ),
              ),
              const SizedBox(height: AppEspacios.l),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: AspectRatio(
                    aspectRatio: 1,
                    // Negro sobre blanco en los dos temas: así lo leen
                    // todas las cámaras.
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppEspacios.radio),
                      child: QrImageView(
                        data: visita.codigoQr,
                        backgroundColor: AppColors.blanco,
                        padding: const EdgeInsets.all(AppEspacios.m),
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                        semanticsLabel: l10n.qrSemantica(
                          visita.nombreResponsable,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppEspacios.l),
              Text(
                visita.nombreResponsable,
                textAlign: TextAlign.center,
                style: textos.titleSmall,
              ),
              Text(
                l10n.hoyGrupo(
                  visita.tamanoGrupo,
                  textoActividades(visita, l10n),
                ),
                textAlign: TextAlign.center,
                style: textos.bodyMedium,
              ),
              const SizedBox(height: AppEspacios.m),
              Text(
                l10n.qrInstruccion,
                textAlign: TextAlign.center,
                style: textos.bodyMedium?.copyWith(
                  color: esquema.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppEspacios.l),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.listo),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
