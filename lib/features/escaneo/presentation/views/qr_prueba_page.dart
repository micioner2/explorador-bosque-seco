import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_espacios.dart';
import '../../../../core/theme/colores_app.dart';
import '../../domain/cartel_qr.dart';
import '../view_models/qr_prueba_view_model.dart';

/// QR de prueba de los puntos de la ruta y del grupo de prueba, para
/// mostrarlos en otro celular o descargarlos en PDF e imprimirlos.
class QrPruebaPage extends ConsumerWidget {
  const QrPruebaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final datos = ref.watch(datosQrPruebaProvider);
    final carteles = cartelesDePrueba(
      l10n,
      puntos: datos.puntos,
      conGrupo: datos.conGrupo,
    );
    final generando = ref.watch(qrPruebaViewModelProvider);

    Future<void> descargar() async {
      final mensajero = ScaffoldMessenger.of(context);
      final listo = await ref
          .read(qrPruebaViewModelProvider.notifier)
          .descargar(l10n);
      if (!listo) {
        mensajero.showSnackBar(SnackBar(content: Text(l10n.pdfError)));
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.qrPruebaTitulo)),
      body: ListView(
        padding: const EdgeInsets.all(AppEspacios.l),
        children: [
          Text(
            l10n.qrPruebaAyuda,
            style: context.textos.bodyMedium?.copyWith(
              color: context.esquema.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppEspacios.m),
          FilledButton.icon(
            onPressed: generando ? null : descargar,
            icon: generando
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            label: Text(generando ? l10n.pdfGenerando : l10n.qrPruebaDescargar),
          ),
          const SizedBox(height: AppEspacios.l),
          for (final cartel in carteles) _TarjetaCartel(cartel: cartel),
        ],
      ),
    );
  }
}

class _TarjetaCartel extends StatelessWidget {
  const _TarjetaCartel({required this.cartel});

  final CartelQr cartel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textos = context.textos;

    return Card(
      margin: const EdgeInsets.only(bottom: AppEspacios.m),
      child: Padding(
        padding: const EdgeInsets.all(AppEspacios.l),
        child: Column(
          children: [
            Text(
              cartel.detalle,
              textAlign: TextAlign.center,
              style: textos.bodyMedium?.copyWith(
                color: context.esquema.onSurfaceVariant,
              ),
            ),
            Text(
              cartel.titulo,
              textAlign: TextAlign.center,
              style: textos.titleLarge,
            ),
            const SizedBox(height: AppEspacios.m),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: AspectRatio(
                aspectRatio: 1,
                // Negro sobre blanco en los dos temas: así lo leen todas
                // las cámaras.
                child: QrImageView(
                  data: cartel.texto,
                  backgroundColor: AppColors.blanco,
                  padding: const EdgeInsets.all(AppEspacios.m),
                  semanticsLabel: cartel.titulo,
                ),
              ),
            ),
            const SizedBox(height: AppEspacios.s),
            SelectableText(
              l10n.qrPruebaCodigo(cartel.codigo),
              textAlign: TextAlign.center,
              style: textos.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
