import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../view_models/sincronizacion_view_model.dart';

/// "Sincronizar ahora": envía lo pendiente y dice cómo fue. No aparece si
/// la app no tiene servidor o si el servidor aún no tiene las tablas.
class BotonSincronizar extends ConsumerWidget {
  const BotonSincronizar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (!ref.watch(sincronizacionDisponibleProvider)) {
      return const SizedBox.shrink();
    }
    final enviando =
        ref.watch(sincronizacionViewModelProvider) == EstadoEnvio.enviando;

    Future<void> sincronizar() async {
      final mensajero = ScaffoldMessenger.of(context);
      final aceptados = await ref
          .read(sincronizacionViewModelProvider.notifier)
          .sincronizar();
      final texto = aceptados != null
          ? l10n.sincronizadoAviso(aceptados)
          : switch (ref.read(sincronizacionViewModelProvider)) {
              EstadoEnvio.sinTablas => l10n.sincronizarSinTablas,
              EstadoEnvio.rechazado => l10n.sincronizarRechazado,
              _ => l10n.sincronizarSinConexion,
            };
      mensajero.showSnackBar(SnackBar(content: Text(texto)));
    }

    return OutlinedButton.icon(
      onPressed: enviando ? null : sincronizar,
      icon: enviando
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.sync),
      label: Text(enviando ? l10n.sincronizando : l10n.sincronizarAhora),
    );
  }
}
