import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/reloj.dart';
import '../../data/puntos_repository_demo.dart';
import '../../domain/escaneo.dart';
import '../../domain/pasaporte.dart';
import '../../domain/producto.dart';

/// Estado y acciones del pasaporte del turista.
class PasaporteViewModel extends Notifier<Pasaporte> {
  @override
  Pasaporte build() => ref.watch(puntosRepositoryProvider).pasaporte();

  /// Registra el escaneo del QR de un punto. Si el punto ya se había
  /// escaneado en esta visita, el pasaporte no cambia.
  ResultadoRegistro registrarEscaneo({
    required String visitaId,
    required String puntoId,
  }) {
    final fecha = ref.read(relojProvider)();
    final resultado = state.registrar(
      Escaneo(
        id: '$visitaId-$puntoId-${fecha.microsecondsSinceEpoch}',
        visitaId: visitaId,
        puntoId: puntoId,
        fecha: fecha,
      ),
    );
    if (resultado is PuntoGanado) state = resultado.pasaporte;
    return resultado;
  }

  /// Aplica la respuesta del servidor tras sincronizar.
  void confirmar(Set<String> idsConfirmados) {
    state = state.confirmar(idsConfirmados);
  }

  /// Canjea puntos por un producto. Lanza [CanjeInvalido] si no alcanzan.
  void canjear(Producto producto) {
    state = state.canjear(producto);
  }
}

final pasaporteViewModelProvider =
    NotifierProvider<PasaporteViewModel, Pasaporte>(PasaporteViewModel.new);

final productosProvider = Provider<List<Producto>>(
  (ref) => ref.watch(puntosRepositoryProvider).productos(),
);
