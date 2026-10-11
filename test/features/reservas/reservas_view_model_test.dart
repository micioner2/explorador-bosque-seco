import 'package:explorador_bosque_seco/core/reloj.dart';
import 'package:explorador_bosque_seco/features/reservas/data/reservas_repository_local.dart';
import 'package:explorador_bosque_seco/features/reservas/domain/reserva.dart';
import 'package:explorador_bosque_seco/features/reservas/domain/reservas_repository.dart';
import 'package:explorador_bosque_seco/features/reservas/presentation/view_models/reservas_view_model.dart';
import 'package:explorador_bosque_seco/features/sesion/data/sesion_repository_demo.dart';
import 'package:explorador_bosque_seco/features/sesion/presentation/view_models/sesion_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _SinReservas implements ReservasRepository {
  @override
  List<Reserva> reservas(DateTime hoy) => const [];

  @override
  Future<void> guardar(Reserva reserva) async {}
}

void main() {
  final ahora = DateTime(2026, 10, 10, 12);
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        relojProvider.overrideWithValue(() => ahora),
        reservasRepositoryProvider.overrideWithValue(_SinReservas()),
        sesionRepositoryProvider.overrideWithValue(
          SesionRepositoryDemo(cuentaGuardada: SesionRepositoryDemo.cuentaDemo),
        ),
      ],
    );
    addTearDown(container.dispose);
    container
        .read(sesionViewModelProvider.notifier)
        .elegirGuia(container.read(guiasDeLaCuentaProvider).first);
  });

  ReservasViewModel viewModel() =>
      container.read(reservasViewModelProvider.notifier);

  Reserva anotar({String nombre = 'Carmen Seminario', int hora = 15}) =>
      viewModel().crear(
        nombreContacto: nombre,
        telefono: '944 300 120',
        fechaHora: DateTime(2026, 10, 10, hora),
        personas: 4,
      );

  test('anota la reserva a nombre de la asociación y del guía', () {
    final reserva = anotar();

    expect(container.read(reservasViewModelProvider), [reserva]);
    expect(reserva.asociacionId, SesionRepositoryDemo.cuentaDemo.asociacionId);
    expect(reserva.nombreGuia, 'Juan Chunga');
    expect(container.read(agendaReservasProvider).deHoy.personas, 4);
  });

  test('cada reserva tiene su propio id, generado en el celular', () {
    final una = anotar();
    final otra = anotar(nombre: 'Diego Flores');

    expect(una.id, isNot(otra.id));
  });

  test('sin guía elegido no se anota', () {
    container.read(sesionViewModelProvider.notifier).cambiarGuia();

    expect(anotar, throwsStateError);
    expect(container.read(reservasViewModelProvider), isEmpty);
  });

  test('con datos inválidos no anota nada', () {
    expect(() => anotar(hora: 9), throwsArgumentError);
    expect(() => anotar(nombre: ' '), throwsArgumentError);
    expect(container.read(reservasViewModelProvider), isEmpty);
  });

  test('reprogramar mueve la reserva en la agenda', () {
    final reserva = anotar();

    viewModel().reprogramar(
      reserva.id,
      fechaHora: DateTime(2026, 10, 11, 9),
      personas: 5,
    );

    final agenda = container.read(agendaReservasProvider);
    expect(agenda.deHoy.reservas, isEmpty);
    expect(agenda.proximas.single.reservas.single.personas, 5);
  });

  test('si el cambio no es válido, la reserva queda igual', () {
    final reserva = anotar();

    expect(
      () => viewModel().reprogramar(
        reserva.id,
        fechaHora: DateTime(2026, 10, 10, 8),
        personas: 4,
      ),
      throwsArgumentError,
    );
    expect(viewModel().buscar(reserva.id)?.fechaHora, reserva.fechaHora);
  });

  test('cancelar la saca de la agenda pero no la borra', () {
    final reserva = anotar();

    viewModel().cancelar(reserva.id);

    expect(container.read(agendaReservasProvider).vacia, isTrue);
    expect(viewModel().buscar(reserva.id)?.estado, EstadoReserva.cancelada);
  });

  test('una reserva que no existe se informa', () {
    expect(() => viewModel().cancelar('no-existe'), throwsArgumentError);
  });
}
