import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/almacen/coleccion_local.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../mapa/presentation/view_models/mapa_view_model.dart';
import '../../../reportes/data/generador_pdf_reporte.dart';
import '../../data/generador_pdf_carteles.dart';
import '../../domain/cartel_qr.dart';
import '../../domain/lectura_qr.dart';

/// Grupo de demostración con sellos de ejemplo (`bosqueseco:visita:v-demo`).
const grupoDePrueba = 'v-demo';

/// Carteles QR para probar el escaneo: el grupo de prueba (solo con datos de
/// demostración) y cada punto de la ruta que muestra la app.
List<CartelQr> cartelesDePrueba(
  AppLocalizations l10n, {
  required List<({String id, String nombre})> puntos,
  required bool conGrupo,
}) => [
  if (conGrupo)
    CartelQr(
      titulo: l10n.qrPruebaGrupo,
      detalle: l10n.qrPruebaGrupoDetalle,
      texto: 'bosqueseco:visita:$grupoDePrueba',
      codigo: 'bosqueseco:visita:$grupoDePrueba',
    ),
  for (final (i, punto) in puntos.indexed)
    CartelQr(
      titulo: punto.nombre,
      detalle: l10n.qrPruebaPunto(i + 1, puntos.length),
      texto: LecturaQr.textoDePunto(punto.id),
      codigo: punto.id,
    ),
];

/// Puntos de la ruta actual y si se ofrece el grupo de prueba.
final datosQrPruebaProvider =
    Provider<({List<({String id, String nombre})> puntos, bool conGrupo})>(
      (ref) => (
        puntos: [
          for (final p in ref.watch(rutaActualProvider).puntos)
            (id: p.id, nombre: p.nombre),
        ],
        conGrupo: ref.watch(datosDemoProvider),
      ),
    );

/// Crea el PDF con los carteles y abre el menú para guardarlo o compartirlo.
/// El estado es `true` mientras se genera.
class QrPruebaViewModel extends Notifier<bool> {
  @override
  bool build() => false;

  Future<bool> descargar(AppLocalizations l10n) async {
    if (state) return false;
    state = true;
    try {
      final datos = ref.read(datosQrPruebaProvider);
      final bytes = await ref
          .read(generadorCartelesProvider)
          .generar(
            cartelesDePrueba(
              l10n,
              puntos: datos.puntos,
              conGrupo: datos.conGrupo,
            ),
            nota: l10n.qrPruebaNota,
          );
      await ref
          .read(compartirArchivoProvider)
          .compartir(bytes, nombreArchivo: 'qr-de-prueba.pdf');
      return true;
    } on Object catch (error) {
      debugPrint('No se pudo crear el PDF de los QR: $error');
      return false;
    } finally {
      if (ref.mounted) state = false;
    }
  }
}

final qrPruebaViewModelProvider = NotifierProvider<QrPruebaViewModel, bool>(
  QrPruebaViewModel.new,
);
