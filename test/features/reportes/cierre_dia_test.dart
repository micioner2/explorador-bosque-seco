import 'package:explorador_bosque_seco/core/almacen/almacen_local.dart';
import 'package:explorador_bosque_seco/core/almacen/coleccion_local.dart';
import 'package:explorador_bosque_seco/core/reloj.dart';
import 'package:explorador_bosque_seco/features/reportes/domain/cierre_dia.dart';
import 'package:explorador_bosque_seco/features/reportes/domain/reporte_diario.dart';
import 'package:explorador_bosque_seco/features/reportes/presentation/view_models/reporte_view_model.dart';
import 'package:explorador_bosque_seco/features/sesion/data/sesion_repository_demo.dart';
import 'package:explorador_bosque_seco/features/sesion/presentation/view_models/sesion_view_model.dart';
import 'package:explorador_bosque_seco/features/visitas/presentation/view_models/visitas_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tarde = DateTime(2026, 10, 10, 18, 5);

  ProviderContainer abrir(AlmacenLocal almacen, {DateTime? ahora}) {
    final container = ProviderContainer(
      overrides: [
        almacenLocalProvider.overrideWithValue(almacen),
        // Las tres visitas de demostración: 9 personas, una con salida
        // vencida y ninguna con salida marcada.
        datosDemoProvider.overrideWithValue(true),
        relojProvider.overrideWithValue(() => ahora ?? tarde),
        sesionRepositoryProvider.overrideWithValue(
          SesionRepositoryDemo(cuentaGuardada: SesionRepositoryDemo.cuentaDemo),
        ),
      ],
    );
    addTearDown(container.dispose);
    final maria = container
        .read(guiasDeLaCuentaProvider)
        .firstWhere((g) => g.nombre == 'María Quispe');
    container.read(sesionViewModelProvider.notifier).elegirGuia(maria);
    return container;
  }

  test('el reporte suma grupos y personas por guía', () {
    final reporte = abrir(AlmacenMemoria()).read(reporteViewModelProvider);

    expect(reporte.porGuia, const [
      ResumenGuia(nombreGuia: 'María Quispe', grupos: 2, personas: 7),
      ResumenGuia(nombreGuia: 'Juan Chunga', grupos: 1, personas: 2),
    ]);
    expect(reporte.gruposSinSalida, 3);
  });

  test('al empezar el día no está cerrado', () {
    expect(abrir(AlmacenMemoria()).read(cierreViewModelProvider), isNull);
  });

  test('cerrar el día guarda las cifras, quién cerró y la hora (R17)', () {
    final app = abrir(AlmacenMemoria());

    final cierre = app.read(cierreViewModelProvider.notifier).cerrarDia();

    expect(cierre.totalGrupos, 3);
    expect(cierre.totalVisitantes, 9);
    expect(cierre.cerradoPor, 'María Quispe');
    expect(cierre.cerradoEn, tarde);
    expect(cierre.porGuia, hasLength(2));
    expect(app.read(cierreViewModelProvider), cierre);
  });

  test('el cierre sigue al volver a abrir la app', () {
    final almacen = AlmacenMemoria();
    abrir(almacen).read(cierreViewModelProvider.notifier).cerrarDia();

    final cierre = abrir(almacen).read(cierreViewModelProvider);

    expect(cierre?.totalVisitantes, 9);
    expect(cierre?.cerradoPor, 'María Quispe');
  });

  test('el cierre de ayer no cuenta como el de hoy', () {
    final almacen = AlmacenMemoria();
    abrir(almacen).read(cierreViewModelProvider.notifier).cerrarDia();

    final manana = abrir(almacen, ahora: tarde.add(const Duration(days: 1)));

    expect(manana.read(cierreViewModelProvider), isNull);
  });

  test('si se marca una salida después de cerrar, el cierre queda '
      'desactualizado', () {
    final app = abrir(AlmacenMemoria());
    final cierre = app.read(cierreViewModelProvider.notifier).cerrarDia();

    final visita = app.read(visitasViewModelProvider).first;
    app.read(visitasViewModelProvider.notifier).marcarSalida(visita.id);

    expect(cierre.desactualizado(app.read(reporteViewModelProvider)), isTrue);
  });

  test('un cierre siempre dice qué guía lo hizo', () {
    expect(
      () => CierreDia(
        dia: DateTime(2026, 10, 10),
        asociacionId: 'demo',
        cerradoEn: tarde,
        cerradoPor: ' ',
        totalGrupos: 0,
        totalVisitantes: 0,
        gruposSinSalida: 0,
        porGuia: const [],
      ),
      throwsArgumentError,
    );
  });
}
