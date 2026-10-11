import 'package:explorador_bosque_seco/features/conexion/data/conexion_repository_supabase.dart';
import 'package:explorador_bosque_seco/features/conexion/domain/conexion_repository.dart';
import 'package:explorador_bosque_seco/features/conexion/domain/estado_conexion.dart';
import 'package:explorador_bosque_seco/features/preferencias/domain/preferencias.dart';
import 'package:explorador_bosque_seco/features/preferencias/presentation/views/ajustes_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/app_de_prueba.dart';

/// Devuelve los estados indicados, uno por cada verificación.
class _RepositorioFalso implements ConexionRepository {
  _RepositorioFalso(this._estados);

  final List<EstadoConexion> _estados;
  int verificaciones = 0;

  @override
  Future<EstadoConexion> verificar() async =>
      _estados[(verificaciones++).clamp(0, _estados.length - 1)];
}

void main() {
  Future<void> abrirAjustes(
    WidgetTester tester,
    ConexionRepository? repositorio, {
    Idioma idioma = Idioma.es,
  }) async {
    // Pantalla alta para que la sección del servidor quede dibujada.
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await montarPantalla(
      tester,
      const AjustesPage(),
      idioma: idioma,
      overrides: [
        if (repositorio != null)
          conexionRepositoryProvider.overrideWithValue(repositorio),
      ],
    );
  }

  testWidgets(
    'sin servidor configurado, explica que usa los datos del celular',
    (tester) async {
      await abrirAjustes(tester, null);

      expect(find.text('Servidor'), findsOneWidget);
      expect(find.text('Sin servidor configurado'), findsOneWidget);
      expect(
        find.text('La app usa los datos guardados en el celular.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('muestra cada resultado de la prueba de conexión', (
    tester,
  ) async {
    final casos = <EstadoConexion, String>{
      const Conectado(esquemaListo: true):
          'El servidor responde y la base de datos está lista.',
      const Conectado(esquemaListo: false):
          'El servidor responde, pero aún no se crean las tablas de la app.',
      const ClaveRechazada(): 'El servidor no aceptó la clave de la app.',
      const SinConexion():
          'No se pudo llegar al servidor. Tus datos siguen guardados en el '
          'celular.',
      const ErrorServidor('500'): 'El servidor respondió con un error (500).',
    };

    for (final MapEntry(key: estado, value: detalle) in casos.entries) {
      await abrirAjustes(tester, _RepositorioFalso([estado]));

      expect(find.text(detalle), findsOneWidget, reason: '$estado');
    }
  });

  testWidgets('"Probar conexión" vuelve a consultar el servidor', (
    tester,
  ) async {
    final repositorio = _RepositorioFalso([
      const SinConexion(),
      const Conectado(esquemaListo: true),
    ]);
    await abrirAjustes(tester, repositorio);
    expect(find.text('Sin conexión'), findsOneWidget);

    await tocar(tester, find.text('Probar conexión'));

    expect(find.text('Conectado'), findsOneWidget);
    expect(repositorio.verificaciones, 2);
  });

  testWidgets('los estados también se muestran en inglés', (tester) async {
    await abrirAjustes(
      tester,
      _RepositorioFalso([const Conectado(esquemaListo: false)]),
      idioma: Idioma.en,
    );

    expect(find.text('Server'), findsOneWidget);
    expect(find.text('Connected'), findsOneWidget);
    expect(find.text('Test connection'), findsOneWidget);
  });
}
