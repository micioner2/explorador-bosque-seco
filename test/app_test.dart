import 'package:explorador_bosque_seco/features/mapa/presentation/views/mapa_page.dart';
import 'package:explorador_bosque_seco/features/preferencias/domain/preferencias.dart';
import 'package:explorador_bosque_seco/features/visitas/presentation/views/hoy_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'ayudas/app_de_prueba.dart';

void main() {
  Finder enDialogo(String texto) =>
      find.descendant(of: find.byType(AlertDialog), matching: find.text(texto));

  testWidgets('abre en Explorar con el espacio, la ruta y sus atractivos', (
    tester,
  ) async {
    await abrirApp(tester);

    expect(find.text('Coto de Caza El Angolo'), findsOneWidget);
    expect(find.text('Antes de ir'), findsOneWidget);
    expect(find.text('Ruta de las Pozas'), findsOneWidget);
    expect(find.text('5 puntos · 4,6 km · 1 h 50 min'), findsOneWidget);
    expect(find.text('Atractivos'), findsOneWidget);
    expect(find.text('Explorar'), findsOneWidget);
  });

  testWidgets('el mapa muestra el siguiente punto con distancia y tiempo', (
    tester,
  ) async {
    await abrirApp(tester);

    await tocar(tester, find.text('Mapa'));

    expect(find.text('4 · Mirador'), findsOneWidget);
    expect(find.text('850 m'), findsOneWidget);
    expect(find.text('20 min'), findsOneWidget);
    expect(find.text('3 de 5 puntos'), findsOneWidget);

    // El recorrido sigue más abajo: la caída de agua se escaneó sin señal.
    await tester.scrollUntilVisible(
      find.text('Pendiente de sincronizar'),
      200,
      scrollable: find.descendant(
        of: find.byType(MapaPage),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('Caída de agua'), findsOneWidget);
  });

  testWidgets('navega al pasaporte y muestra los puntos', (tester) async {
    await abrirApp(tester);

    await tocar(tester, find.text('Pasaporte'));

    expect(find.text('Mi pasaporte'), findsOneWidget);
    expect(find.text('2 confirmados'), findsOneWidget);
    expect(find.text('1 pendiente'), findsOneWidget);
    expect(find.text('Mis sellos'), findsOneWidget);
  });

  testWidgets('escanear un punto suma un sello pendiente al pasaporte', (
    tester,
  ) async {
    await abrirApp(tester);

    await tocar(tester, find.text('Escanear QR'));
    await tocar(tester, find.text('Simular escaneo (demo)'));
    expect(find.text('¡Sello obtenido! +1 punto'), findsOneWidget);

    await tocar(tester, find.text('Simular escaneo (demo)'));
    expect(find.text('Este punto ya está en tu pasaporte'), findsOneWidget);

    await tocar(tester, find.text('Ver pasaporte'));
    expect(find.text('Mi pasaporte'), findsOneWidget);
    expect(find.text('2 pendientes'), findsOneWidget);
  });

  testWidgets('canjear pide confirmación y descuenta los puntos', (
    tester,
  ) async {
    await abrirApp(tester);
    await tocar(tester, find.text('Pasaporte'));

    final botonCanjear = find.widgetWithText(FilledButton, 'Canjear');
    await tocar(tester, botonCanjear);
    expect(find.text('¿Canjear tus puntos?'), findsOneWidget);
    expect(find.text('2 puntos para canjear'), findsOneWidget);

    await tocar(tester, enDialogo('Canjear'));

    expect(find.text('Cupón generado: Miel de algarrobo'), findsOneWidget);
    expect(find.text('0 puntos para canjear'), findsOneWidget);
    expect(find.text('Te faltan 2 puntos'), findsOneWidget);
    expect(botonCanjear, findsNothing);
  });

  testWidgets('cancelar el canje no gasta puntos', (tester) async {
    await abrirApp(tester);
    await tocar(tester, find.text('Pasaporte'));

    await tocar(tester, find.widgetWithText(FilledButton, 'Canjear'));
    await tocar(tester, enDialogo('Cancelar'));

    expect(find.text('2 puntos para canjear'), findsOneWidget);
  });

  group('entrada al puesto de control', () {
    Finder botonEntrar() => find.text('Entrar');

    testWidgets('pide la cuenta de la asociación y luego el guía', (
      tester,
    ) async {
      await abrirApp(tester);

      await tocar(tester, find.byTooltip('Modo asociación'));
      expect(find.text('PASO 1 DE 2'), findsOneWidget);
      expect(find.text('Entra al puesto de control'), findsOneWidget);
      expect(find.text('Solo la primera vez necesitas señal'), findsOneWidget);

      await tocar(tester, find.text('Usar cuenta de prueba'));
      await tocar(tester, botonEntrar());

      expect(find.text('PASO 2 DE 2'), findsOneWidget);
      expect(find.text('¿Quién eres?'), findsOneWidget);
      expect(find.text('Coto de Caza El Angolo'), findsOneWidget);

      await tocar(tester, find.text('María Quispe'));

      expect(find.text('Puesto de control'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(
        find.text('Hola, María Quispe. Ya puedes registrar visitas.'),
        findsOneWidget,
      );
    });

    testWidgets('explica qué falta antes de intentar entrar', (tester) async {
      await abrirApp(tester);
      await tocar(tester, find.byTooltip('Modo asociación'));

      await tocar(tester, botonEntrar());
      expect(find.text('Ingresa el correo de tu asociación'), findsOneWidget);
      expect(find.text('Ingresa la contraseña'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Correo de la asociación'),
        'demo.bosqueseco.pe',
      );
      await tocar(tester, botonEntrar());
      expect(find.text('Revisa el correo: le falta la @'), findsOneWidget);
    });

    testWidgets('con la contraseña equivocada dice qué pasó y no entra', (
      tester,
    ) async {
      await abrirApp(tester);
      await tocar(tester, find.byTooltip('Modo asociación'));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Correo de la asociación'),
        'demo@bosqueseco.pe',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contraseña'),
        'equivocada',
      );
      await tester.pumpAndSettle();
      await tocar(tester, botonEntrar());

      expect(find.text('Correo o contraseña incorrectos'), findsOneWidget);
      expect(find.text('Entra al puesto de control'), findsOneWidget);
    });

    testWidgets('la contraseña se puede mostrar para revisarla', (
      tester,
    ) async {
      await abrirApp(tester);
      await tocar(tester, find.byTooltip('Modo asociación'));
      bool oculta() => tester
          .widget<TextField>(
            find.descendant(
              of: find.widgetWithText(TextFormField, 'Contraseña'),
              matching: find.byType(TextField),
            ),
          )
          .obscureText;
      expect(oculta(), isTrue);

      await tocar(tester, find.byTooltip('Mostrar contraseña'));

      expect(oculta(), isFalse);
      expect(find.byTooltip('Ocultar contraseña'), findsOneWidget);
    });

    testWidgets('al volver del modo turista, la sesión sigue abierta', (
      tester,
    ) async {
      await abrirApp(tester);
      await entrarAlPuesto(tester);

      await tocar(tester, find.byTooltip('Modo turista'));
      expect(find.text('Coto de Caza El Angolo'), findsOneWidget);

      await tocar(tester, find.byTooltip('Modo asociación'));
      expect(find.text('Puesto de control'), findsOneWidget);
    });

    testWidgets('otro guía toma el celular sin volver a entrar', (
      tester,
    ) async {
      await abrirApp(tester);
      await entrarAlPuesto(tester);

      await tocar(tester, find.byTooltip('Tu sesión'));
      expect(find.text('María Quispe'), findsOneWidget);
      await tocar(tester, find.text('Cambiar de guía'));

      expect(find.text('¿Quién eres?'), findsOneWidget);
      await tocar(tester, find.text('Juan Chunga'));
      await tocar(tester, find.text('Registrar'));

      expect(find.text('Registrando como'), findsOneWidget);
      expect(find.text('Juan Chunga'), findsOneWidget);
    });

    testWidgets('salir de la cuenta pide confirmación y vuelve al modo '
        'turista', (tester) async {
      await abrirApp(tester);
      await entrarAlPuesto(tester);

      await tocar(tester, find.byTooltip('Tu sesión'));
      await tocar(tester, find.text('Salir de la cuenta'));
      expect(find.text('¿Salir de la cuenta?'), findsOneWidget);
      await tocar(tester, enDialogo('Salir'));

      expect(find.text('Coto de Caza El Angolo'), findsOneWidget);
      await tocar(tester, find.byTooltip('Modo asociación'));
      expect(find.text('Entra al puesto de control'), findsOneWidget);
    });
  });

  testWidgets('cambia al modo asociación y vuelve al modo turista', (
    tester,
  ) async {
    await abrirApp(tester);

    await entrarAlPuesto(tester);

    expect(find.text('Puesto de control'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tocar(tester, find.byTooltip('Modo turista'));

    expect(find.text('Coto de Caza El Angolo'), findsOneWidget);
  });

  testWidgets('la alerta "sigue dentro" se va al marcar la salida', (
    tester,
  ) async {
    await abrirApp(tester);
    await entrarAlPuesto(tester);

    expect(find.text('1 grupo pasó su hora de salida'), findsOneWidget);
    expect(find.text('Debía salir a las 11:00'), findsOneWidget);

    // El grupo atrasado va primero en la lista.
    await tocar(tester, find.text('Marcar salida').first);
    expect(find.text('¿Marcar la salida?'), findsOneWidget);
    await tocar(tester, enDialogo('Marcar salida'));

    expect(find.text('Salida de Jorge Ramírez registrada'), findsOneWidget);
    expect(find.text('1 grupo pasó su hora de salida'), findsNothing);
    expect(find.text('Jorge Ramírez'), findsNothing);
  });

  group('registro de un grupo', () {
    Future<void> abrirRegistro(WidgetTester tester) async {
      await abrirApp(tester);
      await entrarAlPuesto(tester);
      await tocar(tester, find.text('Registrar'));
    }

    Future<void> escribir(
      WidgetTester tester, {
      required String nombre,
      required String edad,
    }) async {
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre y apellido'),
        nombre,
      );
      await tester.enterText(find.widgetWithText(TextFormField, 'Edad'), edad);
      // Al escribir, Flutter desplaza la pantalla hasta el cursor: se espera
      // a que termine antes de tocar otro botón.
      await tester.pumpAndSettle();
    }

    testWidgets('agrega a cada integrante y genera un solo QR para todos', (
      tester,
    ) async {
      await abrirRegistro(tester);
      expect(find.text('Integrantes (0)'), findsOneWidget);

      await escribir(tester, nombre: 'Rosa Castillo', edad: '41');
      await tocar(tester, find.text('Agregar integrante'));
      await escribir(tester, nombre: 'Pedro Castillo', edad: '44');
      await tocar(tester, find.text('Agregar integrante'));

      expect(find.text('Integrantes (2)'), findsOneWidget);
      expect(find.text('Rosa Castillo'), findsOneWidget);
      expect(find.text('44 años · Piura'), findsOneWidget);
      // Solo la primera persona es la responsable del grupo.
      expect(find.text('Responsable'), findsOneWidget);

      // La tercera persona queda escrita sin tocar "Agregar": también cuenta.
      await escribir(tester, nombre: 'Inés Castillo', edad: '15');
      await tocar(tester, find.text('Senderismo'));
      await tocar(tester, find.text('Fotografía'));
      await tocar(tester, find.text('Registrar grupo y generar QR'));

      expect(find.text('QR del grupo'), findsOneWidget);
      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.text('3 personas · Senderismo, Fotografía'), findsOneWidget);

      await tocar(tester, find.text('Listo'));

      // El formulario queda vacío para el siguiente grupo.
      expect(find.text('Integrantes (0)'), findsOneWidget);
      expect(find.text('Rosa Castillo'), findsNothing);
    });

    testWidgets('el grupo registrado aparece en Hoy con su QR', (tester) async {
      await abrirRegistro(tester);
      await escribir(tester, nombre: 'Rosa Castillo', edad: '41');
      await tocar(tester, find.text('Avistamiento de aves'));
      await tocar(tester, find.text('Registrar grupo y generar QR'));
      await tocar(tester, find.text('Listo'));

      await tocar(tester, find.text('Hoy'));
      await tester.scrollUntilVisible(
        find.text('Rosa Castillo'),
        200,
        scrollable: find.descendant(
          of: find.byType(HoyPage),
          matching: find.byType(Scrollable),
        ),
      );
      expect(find.text('1 persona · Avistamiento de aves'), findsOneWidget);
      // Queda a nombre del guía que lo registró.
      final tarjeta = find.ancestor(
        of: find.text('Rosa Castillo'),
        matching: find.byType(Card),
      );
      expect(
        find.descendant(of: tarjeta, matching: find.text('Guía: María Quispe')),
        findsOneWidget,
      );

      await tocar(tester, find.text('Ver QR').last);
      expect(find.byType(QrImageView), findsOneWidget);
    });

    testWidgets('se puede quitar a un integrante antes de registrar', (
      tester,
    ) async {
      await abrirRegistro(tester);
      await escribir(tester, nombre: 'Rosa Castillo', edad: '41');
      await tocar(tester, find.text('Agregar integrante'));

      await tocar(tester, find.byTooltip('Quitar a Rosa Castillo'));

      expect(find.text('Integrantes (0)'), findsOneWidget);
    });

    testWidgets('no registra sin integrantes ni sin actividades', (
      tester,
    ) async {
      await abrirRegistro(tester);

      await tocar(tester, find.text('Registrar grupo y generar QR'));
      expect(find.text('Ingresa el nombre'), findsOneWidget);
      expect(find.byType(QrImageView), findsNothing);

      await escribir(tester, nombre: 'Rosa Castillo', edad: '41');
      await tocar(tester, find.text('Registrar grupo y generar QR'));
      expect(find.text('Elige al menos una actividad'), findsOneWidget);
      expect(find.byType(QrImageView), findsNothing);
      // Lo escrito no se pierde: Rosa ya quedó en la lista.
      expect(find.text('Integrantes (1)'), findsOneWidget);
    });
  });

  testWidgets('en Ajustes se cambia el idioma a inglés', (tester) async {
    await abrirApp(tester);

    await tocar(tester, find.byTooltip('Ajustes'));
    expect(find.text('Idioma'), findsOneWidget);

    await tocar(tester, find.text('English'));
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Before you go'), findsOneWidget);
    expect(find.text('5 stops · 4.6 km · 1 h 50 min'), findsOneWidget);
  });

  testWidgets('en Ajustes se cambia al modo oscuro', (tester) async {
    await abrirApp(tester);
    Brightness brillo() =>
        Theme.of(tester.element(find.byType(Scaffold).first)).brightness;
    expect(brillo(), Brightness.light);

    await tocar(tester, find.byTooltip('Ajustes'));
    await tocar(tester, find.text('Oscuro'));

    expect(brillo(), Brightness.dark);
  });

  testWidgets('respeta el idioma y la apariencia guardados', (tester) async {
    await abrirApp(tester, idioma: Idioma.en, modoTema: ModoTema.oscuro);

    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Points of interest'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
      Brightness.dark,
    );
  });
}
