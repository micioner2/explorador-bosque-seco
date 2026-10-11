import 'package:explorador_bosque_seco/core/almacen/almacen_local.dart';
import 'package:explorador_bosque_seco/core/almacen/coleccion_local.dart';
import 'package:explorador_bosque_seco/core/id.dart';
import 'package:explorador_bosque_seco/core/reloj.dart';
import 'package:explorador_bosque_seco/features/puntos/domain/escaneo.dart';
import 'package:explorador_bosque_seco/features/puntos/presentation/view_models/pasaporte_view_model.dart';
import 'package:explorador_bosque_seco/features/reportes/domain/cierre_dia.dart';
import 'package:explorador_bosque_seco/features/reportes/presentation/view_models/reporte_view_model.dart';
import 'package:explorador_bosque_seco/features/sesion/data/sesion_repository_demo.dart';
import 'package:explorador_bosque_seco/features/sesion/domain/cuenta_asociacion.dart';
import 'package:explorador_bosque_seco/features/sesion/presentation/view_models/sesion_view_model.dart';
import 'package:explorador_bosque_seco/features/sincronizacion/data/red_repository_conectividad.dart';
import 'package:explorador_bosque_seco/features/sincronizacion/data/sincronizacion_repository_supabase.dart';
import 'package:explorador_bosque_seco/features/sincronizacion/domain/estado_sincronizacion.dart';
import 'package:explorador_bosque_seco/features/sincronizacion/domain/sincronizacion_repository.dart';
import 'package:explorador_bosque_seco/features/sincronizacion/presentation/view_models/sincronizacion_view_model.dart';
import 'package:explorador_bosque_seco/features/visitas/domain/visita.dart';
import 'package:explorador_bosque_seco/features/visitas/presentation/view_models/visitas_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/app_de_prueba.dart';

/// Servidor en memoria con las mismas reglas que las tablas: una fila por
/// id y un sello por visita y punto (R1).
class _ServidorDePrueba implements SincronizacionRepository {
  final visitas = <String, Visita>{};
  final sellos = <String, Escaneo>{};
  final cierres = <String, CierreDia>{};
  int envios = 0;
  bool sinSenal = false;

  void _revisar() {
    envios++;
    if (sinSenal) {
      throw const SincronizacionFallida(FalloSincronizacion.sinConexion);
    }
  }

  @override
  Future<Set<String>> enviarVisitas(Iterable<Visita> lote) async {
    _revisar();
    for (final v in lote) {
      visitas[v.id] = v;
    }
    return {for (final v in lote) v.id};
  }

  @override
  Future<Set<String>> enviarEscaneos(Iterable<Escaneo> lote) async {
    _revisar();
    for (final e in lote) {
      sellos.putIfAbsent(e.clave, () => e);
    }
    return {for (final e in lote) e.id};
  }

  @override
  Future<Set<String>> enviarCierres(Iterable<CierreDia> lote) async {
    _revisar();
    for (final c in lote) {
      cierres[claveCierre(c.asociacionId, c.dia)] = c;
    }
    return {for (final c in lote) claveCierre(c.asociacionId, c.dia)};
  }
}

void main() {
  final ahora = DateTime(2026, 10, 11, 18);
  final cuenta = CuentaAsociacion(
    asociacionId: nuevoId(),
    nombreAsociacion: 'Asociación El Angolo',
    correo: 'angolo@bosqueseco.pe',
  );
  late _ServidorDePrueba servidor;

  ProviderContainer abrir(AlmacenLocal almacen) {
    final app = ProviderContainer(
      overrides: [
        relojProvider.overrideWithValue(() => ahora),
        almacenLocalProvider.overrideWithValue(almacen),
        datosDemoProvider.overrideWithValue(false),
        sesionRepositoryProvider.overrideWithValue(
          SesionRepositoryDemo(cuentaGuardada: cuenta),
        ),
        sincronizacionRepositoryProvider.overrideWithValue(servidor),
        redRepositoryProvider.overrideWithValue(const RedDePrueba()),
      ],
    );
    addTearDown(app.dispose);
    app.listen(estadoPuestoProvider, (_, _) {});
    return app;
  }

  void registrarYCerrar(ProviderContainer app) {
    app
        .read(sesionViewModelProvider.notifier)
        .elegirGuia(app.read(guiasDeLaCuentaProvider).first);
    app
        .read(visitasViewModelProvider.notifier)
        .registrar(
          integrantes: [
            Visitante(
              nombre: 'Rosa Castillo',
              documento: '45120300',
              edad: 41,
              procedencia: Procedencia.piura,
            ),
          ],
          actividades: [Actividad.aves],
        );
    app
        .read(pasaporteViewModelProvider.notifier)
        .registrarEscaneo(visitaId: nuevoId(), puntoId: 'mirador');
    app.read(cierreViewModelProvider.notifier).cerrarDia();
  }

  setUp(() => servidor = _ServidorDePrueba());

  test('envía grupo, sello y cierre, y todo queda confirmado', () async {
    final app = abrir(AlmacenMemoria());
    registrarYCerrar(app);
    expect(app.read(pendientesPuestoProvider), 2);

    final aceptados = await app
        .read(sincronizacionViewModelProvider.notifier)
        .sincronizar();

    expect(aceptados, 3);
    expect(servidor.visitas, hasLength(1));
    expect(servidor.sellos, hasLength(1));
    expect(servidor.cierres, hasLength(1));
    expect(app.read(pendientesPuestoProvider), 0);
    expect(app.read(pasaporteViewModelProvider).puntosConfirmados, 1);
    expect(app.read(pasaporteViewModelProvider).puntosPendientes, 0);
  });

  test(
    'reenviar no duplica: el servidor guarda cada registro una vez',
    () async {
      final app = abrir(AlmacenMemoria());
      registrarYCerrar(app);
      final sincronizacion = app.read(sincronizacionViewModelProvider.notifier);

      await sincronizacion.sincronizar();
      // Otro celular reenvía el mismo sello (mismo grupo y punto, otro id).
      final sello = servidor.sellos.values.single;
      await servidor.enviarEscaneos([
        Escaneo(
          id: nuevoId(),
          visitaId: sello.visitaId,
          puntoId: sello.puntoId,
          fecha: ahora,
        ),
      ]);
      await sincronizacion.sincronizar();

      expect(servidor.visitas, hasLength(1));
      expect(servidor.sellos, hasLength(1));
      expect(servidor.cierres, hasLength(1));
    },
  );

  test(
    'lo confirmado no se vuelve a enviar al abrir la app otra vez',
    () async {
      final almacen = AlmacenMemoria();
      final antes = abrir(almacen);
      registrarYCerrar(antes);
      await antes.read(sincronizacionViewModelProvider.notifier).sincronizar();

      final despues = abrir(almacen);

      expect(despues.read(pendientesPuestoProvider), 0);
      expect(despues.read(estadoPuestoProvider), isA<SinSenal>());
    },
  );

  test('si después se marca la salida, el grupo vuelve a enviarse', () async {
    final app = abrir(AlmacenMemoria());
    registrarYCerrar(app);
    final sincronizacion = app.read(sincronizacionViewModelProvider.notifier);
    await sincronizacion.sincronizar();
    final visita = app.read(visitasViewModelProvider).single;

    app.read(visitasViewModelProvider.notifier).marcarSalida(visita.id);
    expect(app.read(pendientesPuestoProvider), greaterThan(0));
    await sincronizacion.sincronizar();

    expect(servidor.visitas[visita.id]?.salio, isTrue);
    expect(servidor.visitas, hasLength(1));
  });

  test('sin señal, todo sigue pendiente y el estado lo dice', () async {
    final app = abrir(AlmacenMemoria());
    registrarYCerrar(app);
    servidor.sinSenal = true;

    final aceptados = await app
        .read(sincronizacionViewModelProvider.notifier)
        .sincronizar();

    expect(aceptados, isNull);
    expect(app.read(sincronizacionViewModelProvider), EstadoEnvio.sinConexion);
    expect(app.read(pendientesPuestoProvider), 2);
    expect(app.read(pasaporteViewModelProvider).puntosPendientes, 1);
  });

  test('sin servidor configurado no hay botón ni envío', () async {
    final app = ProviderContainer(
      overrides: [almacenLocalProvider.overrideWithValue(AlmacenMemoria())],
    );
    addTearDown(app.dispose);

    expect(app.read(sincronizacionDisponibleProvider), isFalse);
    expect(
      await app.read(sincronizacionViewModelProvider.notifier).sincronizar(),
      isNull,
    );
  });

  test('los datos de demostración nunca se envían (ids que no son UUID)', () {
    expect(SincronizacionRepositorySupabase.esUuid('v-demo'), isFalse);
    expect(SincronizacionRepositorySupabase.esUuid(nuevoId()), isTrue);
  });
}
