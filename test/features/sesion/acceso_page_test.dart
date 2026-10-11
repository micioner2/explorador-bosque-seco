import 'package:explorador_bosque_seco/features/preferencias/domain/preferencias.dart';
import 'package:explorador_bosque_seco/features/sesion/data/guias_repository_demo.dart';
import 'package:explorador_bosque_seco/features/sesion/data/sesion_repository_demo.dart';
import 'package:explorador_bosque_seco/features/sesion/domain/cuenta_asociacion.dart';
import 'package:explorador_bosque_seco/features/sesion/domain/guia.dart';
import 'package:explorador_bosque_seco/features/sesion/domain/guias_repository.dart';
import 'package:explorador_bosque_seco/features/sesion/domain/resultado_acceso.dart';
import 'package:explorador_bosque_seco/features/sesion/domain/sesion.dart';
import 'package:explorador_bosque_seco/features/sesion/domain/sesion_repository.dart';
import 'package:explorador_bosque_seco/features/sesion/presentation/views/acceso_page.dart';
import 'package:explorador_bosque_seco/features/sesion/presentation/views/elegir_guia_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/app_de_prueba.dart';

/// Servidor que siempre rechaza la cuenta por el mismo motivo.
class _Rechaza implements SesionRepository {
  const _Rechaza(this.motivo);

  final MotivoRechazo motivo;

  @override
  CuentaAsociacion? cuentaGuardada() => null;

  @override
  Future<ResultadoAcceso> iniciarSesion({
    required String correo,
    required String clave,
  }) async => AccesoDenegado(motivo);

  @override
  Future<void> cerrarSesion() async {}
}

class _SinGuias implements GuiasRepository {
  @override
  List<Guia> guiasDe(String asociacionId) => const [];
}

void main() {
  const titulos = {
    MotivoRechazo.credencialesIncorrectas: 'Correo o contraseña incorrectos',
    MotivoRechazo.cuentaNoHabilitada: 'Esta cuenta no está habilitada',
    MotivoRechazo.sinConexion: 'Sin señal para entrar',
    MotivoRechazo.demasiadosIntentos: 'Demasiados intentos',
    MotivoRechazo.errorDelServidor: 'No se pudo entrar',
  };

  Future<void> intentarEntrar(
    WidgetTester tester,
    MotivoRechazo motivo, {
    bool oscuro = false,
    Idioma idioma = Idioma.es,
  }) async {
    await montarPantalla(
      tester,
      const AccesoPage(),
      oscuro: oscuro,
      idioma: idioma,
      sesion: const Sesion(),
      overrides: [sesionRepositoryProvider.overrideWithValue(_Rechaza(motivo))],
    );
    final campos = find.byType(TextFormField);
    await tester.enterText(campos.first, 'angolo@ejemplo.pe');
    await tester.enterText(campos.last, 'clave');
    await tester.pumpAndSettle();
    // El botón "Entrar", en cualquier idioma.
    await tocar(tester, find.byIcon(Icons.login));
  }

  for (final oscuro in [false, true]) {
    group('modo ${oscuro ? 'oscuro' : 'claro'}', () {
      for (final MapEntry(key: motivo, value: titulo) in titulos.entries) {
        testWidgets('el aviso "$titulo" se lee y se anuncia', (tester) async {
          final semantica = tester.ensureSemantics();

          await intentarEntrar(tester, motivo, oscuro: oscuro);

          expect(find.text(titulo), findsOneWidget);
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          semantica.dispose();
        });
      }
    });
  }

  for (final idioma in Idioma.values) {
    testWidgets('los avisos no se desbordan con letra grande '
        '(${idioma.codigo})', (tester) async {
      tester.view.physicalSize = const Size(320, 3600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await intentarEntrar(tester, MotivoRechazo.sinConexion, idioma: idioma);

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('con servidor no ofrece la cuenta de prueba', (tester) async {
    await montarPantalla(
      tester,
      const AccesoPage(),
      sesion: const Sesion(),
      overrides: [
        sesionRepositoryProvider.overrideWithValue(
          const _Rechaza(MotivoRechazo.sinConexion),
        ),
      ],
    );

    expect(find.text('Usar cuenta de prueba'), findsNothing);
  });

  testWidgets('la cuenta de prueba entra con un solo toque', (tester) async {
    await montarPantalla(tester, const AccesoPage(), sesion: const Sesion());

    await tocar(tester, find.text('Usar cuenta de prueba'));

    expect(find.text(SesionRepositoryDemo.correoDemo), findsOneWidget);
  });

  testWidgets('si la asociación no tiene guías, dice cómo resolverlo', (
    tester,
  ) async {
    await montarPantalla(
      tester,
      const ElegirGuiaPage(),
      sesion: const Sesion(cuenta: SesionRepositoryDemo.cuentaDemo),
      overrides: [guiasRepositoryProvider.overrideWithValue(_SinGuias())],
    );

    expect(find.text('Tu asociación aún no tiene guías'), findsOneWidget);
    expect(find.text('Salir de la cuenta'), findsOneWidget);
  });
}
