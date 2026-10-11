import 'package:explorador_bosque_seco/features/preferencias/data/preferencias_repository_local.dart';
import 'package:explorador_bosque_seco/features/preferencias/domain/preferencias.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<PreferenciasRepositoryLocal> abrir([
    Map<String, Object> guardado = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(guardado);
    return PreferenciasRepositoryLocal(await SharedPreferences.getInstance());
  }

  test(
    'la primera vez no hay idioma elegido y el tema sigue al celular',
    () async {
      final repositorio = await abrir();

      expect(repositorio.leer(), const Preferencias());
    },
  );

  test('lo guardado se recupera al volver a abrir la app', () async {
    final repositorio = await abrir();
    const elegidas = Preferencias(idioma: Idioma.en, modoTema: ModoTema.oscuro);

    await repositorio.guardar(elegidas);

    final alReabrir = PreferenciasRepositoryLocal(
      await SharedPreferences.getInstance(),
    );
    expect(alReabrir.leer(), elegidas);
  });

  test(
    'un valor guardado que ya no existe vuelve al valor por defecto',
    () async {
      final repositorio = await abrir({
        'preferencias.idioma': 'fr',
        'preferencias.tema': 'sepia',
      });

      expect(repositorio.leer(), const Preferencias());
    },
  );
}
