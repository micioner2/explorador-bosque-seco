import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../mapa/domain/coordenada.dart';
import '../../data/preferencias_repository_memoria.dart';
import '../../domain/preferencias.dart';

/// Estado y acciones de las preferencias: idioma y apariencia.
class PreferenciasViewModel extends Notifier<Preferencias> {
  @override
  Preferencias build() => ref.watch(preferenciasRepositoryProvider).leer();

  Future<void> cambiarIdioma(Idioma idioma) =>
      _guardar(state.conIdioma(idioma));

  Future<void> cambiarModoTema(ModoTema modoTema) =>
      _guardar(state.conModoTema(modoTema));

  Future<void> cambiarRutaDemo(RutaDemo rutaDemo) =>
      _guardar(state.conRutaDemo(rutaDemo));

  Future<void> centrarSedeEn(Coordenada centro) =>
      _guardar(state.conCentroSede(centro));

  /// Aplica el cambio de inmediato y luego lo guarda en el celular.
  Future<void> _guardar(Preferencias preferencias) {
    state = preferencias;
    return ref.read(preferenciasRepositoryProvider).guardar(preferencias);
  }
}

final preferenciasViewModelProvider =
    NotifierProvider<PreferenciasViewModel, Preferencias>(
      PreferenciasViewModel.new,
    );
