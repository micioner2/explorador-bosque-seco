import 'package:explorador_bosque_seco/features/preferencias/data/preferencias_repository_memoria.dart';
import 'package:explorador_bosque_seco/features/preferencias/domain/preferencias.dart';
import 'package:explorador_bosque_seco/features/preferencias/presentation/view_models/preferencias_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PreferenciasRepositoryMemoria repositorio;
  late ProviderContainer container;

  void crearContainer([Preferencias guardadas = const Preferencias()]) {
    repositorio = PreferenciasRepositoryMemoria(guardadas);
    container = ProviderContainer(
      overrides: [
        preferenciasRepositoryProvider.overrideWithValue(repositorio),
      ],
    );
    addTearDown(container.dispose);
  }

  PreferenciasViewModel viewModel() =>
      container.read(preferenciasViewModelProvider.notifier);

  Preferencias estado() => container.read(preferenciasViewModelProvider);

  test('sin nada guardado usa el idioma y el tema del celular', () {
    crearContainer();

    expect(estado().idioma, isNull);
    expect(estado().modoTema, ModoTema.sistema);
  });

  test('empieza con lo que la persona guardó la última vez', () {
    crearContainer(
      const Preferencias(idioma: Idioma.en, modoTema: ModoTema.oscuro),
    );

    expect(estado().idioma, Idioma.en);
    expect(estado().modoTema, ModoTema.oscuro);
  });

  test('cambiar el idioma se aplica y se guarda sin tocar el tema', () async {
    crearContainer(const Preferencias(modoTema: ModoTema.oscuro));

    await viewModel().cambiarIdioma(Idioma.en);

    expect(estado().idioma, Idioma.en);
    expect(estado().modoTema, ModoTema.oscuro);
    expect(repositorio.leer(), estado());
  });

  test('cambiar el tema se aplica y se guarda sin tocar el idioma', () async {
    crearContainer(const Preferencias(idioma: Idioma.es));

    await viewModel().cambiarModoTema(ModoTema.claro);

    expect(estado().modoTema, ModoTema.claro);
    expect(estado().idioma, Idioma.es);
    expect(repositorio.leer(), estado());
  });
}
