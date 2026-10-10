import 'package:explorador_bosque_seco/core/reloj.dart';
import 'package:explorador_bosque_seco/features/visitas/data/visitas_repository_demo.dart';
import 'package:explorador_bosque_seco/features/visitas/domain/visita.dart';
import 'package:explorador_bosque_seco/features/visitas/domain/visitas_repository.dart';
import 'package:explorador_bosque_seco/features/visitas/presentation/view_models/visitas_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repositorio vacío para probar el ViewModel sin datos de demostración.
class _SinVisitas implements VisitasRepository {
  @override
  List<Visita> visitasDelDia(DateTime dia) => const [];
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
      ],
    );
    addTearDown(container.dispose);
  });

  VisitasViewModel viewModel() =>
      container.read(visitasViewModelProvider.notifier);

  test('registrar agrega la visita con la hora actual', () {
    final visita = viewModel().registrar(
      nombreResponsable: '  Ana Torres ',
      edad: 34,
      procedencia: Procedencia.piura,
      tamanoGrupo: 4,
      actividad: Actividad.senderismo,
    );

    expect(container.read(visitasViewModelProvider), [visita]);
    expect(visita.nombreResponsable, 'Ana Torres');
    expect(visita.fechaEntrada, ahora);
  });

  test('registrar con datos inválidos no agrega nada', () {
    expect(
      () => viewModel().registrar(
        nombreResponsable: 'Ana',
        edad: 34,
        procedencia: Procedencia.piura,
        tamanoGrupo: 0,
        actividad: Actividad.senderismo,
      ),
      throwsArgumentError,
    );
    expect(container.read(visitasViewModelProvider), isEmpty);
  });

  test('marcar salida actualiza el resumen del día', () {
    final visita = viewModel().registrar(
      nombreResponsable: 'Ana',
      edad: 34,
      procedencia: Procedencia.piura,
      tamanoGrupo: 4,
      actividad: Actividad.aves,
    );
    expect(container.read(resumenDelDiaProvider).personasDentro, 4);

    viewModel().marcarSalida(visita.id);

    final resumen = container.read(resumenDelDiaProvider);
    expect(resumen.personasDentro, 0);
    expect(resumen.personasQueSalieron, 4);
  });
}
