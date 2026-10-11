import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/id.dart';
import '../../../../core/reloj.dart';
import '../../data/cupones_repository_local.dart';
import '../../data/puntos_repository_local.dart';
import '../../domain/cupon.dart';
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
        id: nuevoId(),
        visitaId: visitaId,
        puntoId: puntoId,
        fecha: fecha,
      ),
    );
    if (resultado is PuntoGanado) _guardar(resultado.pasaporte);
    return resultado;
  }

  /// Aplica la respuesta del servidor tras sincronizar.
  void confirmar(Set<String> idsConfirmados) {
    _guardar(state.confirmar(idsConfirmados));
  }

  /// Canjea puntos por un producto y entrega el cupón con su QR. Lanza
  /// [CanjeInvalido] si no alcanzan (y no se emite cupón).
  Cupon canjear(Producto producto) {
    _guardar(state.canjear(producto));
    return ref.read(cuponesViewModelProvider.notifier).emitir(producto);
  }

  /// Muestra el cambio de inmediato y lo guarda en el celular.
  void _guardar(Pasaporte pasaporte) {
    state = pasaporte;
    ref.read(puntosRepositoryProvider).guardar(pasaporte);
  }
}

/// Cupones que el turista obtuvo al canjear, guardados en el celular.
class CuponesViewModel extends Notifier<List<Cupon>> {
  @override
  List<Cupon> build() => ref.watch(cuponesRepositoryProvider).cupones();

  Cupon emitir(Producto producto) {
    final cupon = Cupon(
      id: nuevoId(),
      productoId: producto.id,
      nombreProducto: producto.nombre,
      porcentajeDescuento: producto.porcentajeDescuento,
      emitido: ref.read(relojProvider)(),
    );
    state = [...state, cupon];
    ref.read(cuponesRepositoryProvider).guardarCupones(state);
    return cupon;
  }
}

final cuponesViewModelProvider =
    NotifierProvider<CuponesViewModel, List<Cupon>>(CuponesViewModel.new);

/// Cupones que el puesto de control ya aceptó en la tienda (A5).
class CuponesUsadosViewModel extends Notifier<CuponesUsados> {
  @override
  CuponesUsados build() =>
      CuponesUsados(ref.watch(cuponesRepositoryProvider).usados());

  /// Valida el cupón; si es válido, queda usado para no aplicarlo dos veces.
  ValidacionCupon validar({
    required String id,
    required String productoId,
    required int porcentaje,
  }) {
    final validacion = state.validar(
      id: id,
      productoId: productoId,
      porcentaje: porcentaje,
    );
    if (validacion is CuponValido) {
      state = state.usar(id);
      ref.read(cuponesRepositoryProvider).guardarUsados(state.ids);
    }
    return validacion;
  }
}

final cuponesUsadosViewModelProvider =
    NotifierProvider<CuponesUsadosViewModel, CuponesUsados>(
      CuponesUsadosViewModel.new,
    );

final pasaporteViewModelProvider =
    NotifierProvider<PasaporteViewModel, Pasaporte>(PasaporteViewModel.new);

final productosProvider = Provider<List<Producto>>(
  (ref) => ref.watch(puntosRepositoryProvider).productos(),
);
