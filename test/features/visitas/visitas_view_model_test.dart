import 'package:explorador_bosque_seco/core/reloj.dart';
import 'package:explorador_bosque_seco/features/sesion/data/sesion_repository_demo.dart';
import 'package:explorador_bosque_seco/features/sesion/presentation/view_models/sesion_view_model.dart';
import 'package:explorador_bosque_seco/features/visitas/data/visitas_repository_local.dart';
import 'package:explorador_bosque_seco/features/visitas/domain/visita.dart';
import 'package:explorador_bosque_seco/features/visitas/domain/visitas_repository.dart';
import 'package:explorador_bosque_seco/features/visitas/presentation/view_models/visitas_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repositorio vacío para probar el ViewModel sin datos de demostración.
class _SinVisitas implements VisitasRepository {
  @override
  List<Visita> visitasDelDia(DateTime dia) => const [];

  @override
  Future<void> guardar(Visita visita) async {}
}

void main() {
  late DateTime ahora;
  late ProviderContainer container;

  setUp(() {
    ahora = DateTime(2026, 10, 10, 9);
    container = ProviderContainer(
      overrides: [
        relojProvider.overrideWithValue(() => ahora),
        visitasRepositoryProvider.overrideWithValue(_SinVisitas()),
        sesionRepositoryProvider.overrideWithValue(
          SesionRepositoryDemo(cuentaGuardada: SesionRepositoryDemo.cuentaDemo),
        ),
      ],
    );
    addTearDown(container.dispose);
    // Entró la asociación y eligió su nombre el primer guía de la lista.
    container
        .read(sesionViewModelProvider.notifier)
        .elegirGuia(container.read(guiasDeLaCuentaProvider).first);
  });

  VisitasViewModel viewModel() =>
      container.read(visitasViewModelProvider.notifier);

  List<Visitante> familia(int personas) => [
    for (var i = 1; i <= personas; i++)
      Visitante(
        nombre: i == 1 ? '  Ana Torres ' : 'Integrante $i',
        documento: '4000000$i',
        edad: 20 + i,
        procedencia: Procedencia.piura,
      ),
  ];

  test('registrar agrega la visita del grupo con la hora actual', () {
    final visita = viewModel().registrar(
      integrantes: familia(4),
      actividades: const [Actividad.senderismo, Actividad.fotografia],
    );

    expect(container.read(visitasViewModelProvider), [visita]);
    expect(visita.nombreResponsable, 'Ana Torres');
    expect(visita.tamanoGrupo, 4);
    expect(visita.actividades, {Actividad.senderismo, Actividad.fotografia});
    expect(visita.fechaEntrada, ahora);
  });

  test('la visita queda a nombre de la asociación y del guía', () {
    final visita = viewModel().registrar(
      integrantes: familia(2),
      actividades: const [Actividad.aves],
    );

    expect(visita.asociacionId, SesionRepositoryDemo.cuentaDemo.asociacionId);
    expect(visita.guiaId, 'g2');
    expect(visita.nombreGuia, 'Juan Chunga');
  });

  test('sin guía elegido no se registra (R12)', () {
    container.read(sesionViewModelProvider.notifier).cambiarGuia();

    expect(
      () => viewModel().registrar(
        integrantes: familia(2),
        actividades: const [Actividad.aves],
      ),
      throwsStateError,
    );
    expect(container.read(visitasViewModelProvider), isEmpty);
  });

  test('un grupo de cinco personas queda en una sola visita', () {
    viewModel().registrar(
      integrantes: familia(5),
      actividades: const [Actividad.aves],
    );

    expect(container.read(visitasViewModelProvider), hasLength(1));
    expect(container.read(resumenDelDiaProvider).personasDentro, 5);
  });

  test('registrar con datos inválidos no agrega nada', () {
    expect(
      () => viewModel().registrar(
        integrantes: const [],
        actividades: const [Actividad.senderismo],
      ),
      throwsArgumentError,
    );
    expect(
      () =>
          viewModel().registrar(integrantes: familia(2), actividades: const []),
      throwsArgumentError,
    );
    expect(container.read(visitasViewModelProvider), isEmpty);
  });

  test('marcar salida actualiza el resumen del día', () {
    final visita = viewModel().registrar(
      integrantes: familia(4),
      actividades: const [Actividad.aves],
    );
    expect(container.read(resumenDelDiaProvider).personasDentro, 4);

    viewModel().marcarSalida(visita.id);

    final resumen = container.read(resumenDelDiaProvider);
    expect(resumen.personasDentro, 0);
    expect(resumen.personasQueSalieron, 4);
  });
}
