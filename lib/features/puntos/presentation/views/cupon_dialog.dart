import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_espacios.dart';
import '../../../../core/theme/colores_app.dart';
import '../../domain/cupon.dart';

/// Muestra el QR del cupón para enseñarlo en la tienda de la comunidad.
Future<void> mostrarCupon(BuildContext context, Cupon cupon) =>
    showDialog<void>(
      context: context,
      builder: (context) => _CuponDialog(cupon: cupon),
    );

class _CuponDialog extends StatelessWidget {
  const _CuponDialog({required this.cupon});

  final Cupon cupon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
                  l10n.cuponTitulo,
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
                        data: cupon.codigoQr,
                        backgroundColor: AppColors.blanco,
                        padding: const EdgeInsets.all(AppEspacios.m),
                        semanticsLabel: l10n.cuponQrSemantica(
                          cupon.nombreProducto,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppEspacios.l),
              Text(
                l10n.cuponDetalle(
                  cupon.porcentajeDescuento,
                  cupon.nombreProducto,
                ),
                textAlign: TextAlign.center,
                style: textos.bodyMedium,
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
