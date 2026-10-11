import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_espacios.dart';
import '../../../../core/theme/colores_app.dart';

/// Construye la vista de la cámara. [alLeer] recibe el texto de cada QR.
typedef ConstructorVisor =
    Widget Function(BuildContext context, ValueChanged<String> alLeer);

/// Cámara que usa la pantalla de escaneo. Las pruebas la sustituyen, porque
/// no hay cámara donde corren.
final visorCamaraProvider = Provider<ConstructorVisor>(
  (ref) =>
      (context, alLeer) => VisorCamara(alLeer: alLeer),
);

/// Cámara con `mobile_scanner`: lee solo QR y no necesita señal (el lector
/// viene dentro de la app).
class VisorCamara extends StatefulWidget {
  const VisorCamara({required this.alLeer, super.key});

  final ValueChanged<String> alLeer;

  @override
  State<VisorCamara> createState() => _VisorCamaraState();
}

class _VisorCamaraState extends State<VisorCamara> {
  final _controlador = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );

  /// Mientras el mismo QR siga frente a la cámara, se lee una sola vez.
  String? _ultimo;

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _detectar(BarcodeCapture captura) {
    final texto = captura.barcodes.firstOrNull?.rawValue;
    if (texto == null || texto == _ultimo) return;
    _ultimo = texto;
    HapticFeedback.mediumImpact();
    widget.alLeer(texto);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.escanearCamara,
      child: MobileScanner(
        controller: _controlador,
        onDetect: _detectar,
        errorBuilder: (context, error) => const _SinCamara(),
      ),
    );
  }
}

/// Sin permiso o sin cámara: se explica cómo seguir.
class _SinCamara extends StatelessWidget {
  const _SinCamara();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ColoredBox(
      color: context.esquema.surfaceContainerHighest,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppEspacios.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_outlined, size: 40),
              const SizedBox(height: AppEspacios.s),
              Text(
                l10n.escanearSinCamara,
                textAlign: TextAlign.center,
                style: context.textos.titleSmall,
              ),
              const SizedBox(height: AppEspacios.xs),
              Text(
                l10n.escanearSinCamaraDetalle,
                textAlign: TextAlign.center,
                style: context.textos.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
