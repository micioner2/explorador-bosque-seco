import 'package:explorador_bosque_seco/core/reloj.dart';
import 'package:explorador_bosque_seco/features/reservas/domain/reserva.dart';
import 'package:explorador_bosque_seco/features/reservas/presentation/view_models/reservas_view_model.dart';
import 'package:explorador_bosque_seco/features/sesion/data/sesion_repository_demo.dart';
import 'package:explorador_bosque_seco/features/sesion/presentation/view_models/sesion_view_model.dart';
import 'package:explorador_bosque_seco/features/visitas/data/visitas_repository_demo.dart';
import 'package:explorador_bosque_seco/features/visitas/domain/visita.dart';
import 'package:explorador_bosque_seco/features/visitas/domain/visitas_repository.dart';
import 'package:explorador_bosque_seco/features/visitas/presentation/view_models/registro_grupo_view_model.dart';
import 'package:explorador_bosque_seco/features/visitas/presentation/view_models/visitas_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _SinVisitas implements VisitasRepository {
  @override
  List<Visita> visitasDelDia(DateTime dia) => const [];
}

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        relojProvider.overrideWithValue(() => DateTime(2026, 10, 10, 9)),
        visitasRepositoryProvider.overrideWithValue(_SinVisitas()),
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

  RegistroGrupoViewModel viewModel() =>
      container.read(registroGrupoViewModelProvider.notifier);

  BorradorGrupo borrador() => container.read(registroGrupoViewModelProvider);

  void agregar(String nombre, {int edad = 30}) => viewModel().agregarIntegrante(
    nombre: nombre,
    documento: '40000000',
    edad: edad,
    procedencia: Procedencia.piura,
  );

  test('el formulario empieza vacío y no se puede registrar', () {
    expect(borrador().integrantes, isEmpty);
    expect(borrador().actividades, isEmpty);
    expect(borrador().completo, isFalse);
  });

  test('cada integrante se agrega por separado y en orden', () {
    agregar('Ana Torres', edad: 34);
    agregar('Carlos Torres', edad: 36);

    expect(borrador().integrantes.map((i) => i.nombre), [
      'Ana Torres',
      'Carlos Torres',
    ]);
    expect(borrador().integrantes.first.edad, 34);
  });

  test('no agrega integrantes con datos inválidos', () {
    expect(() => agregar('   '), throwsArgumentError);
    expect(() => agregar('Ana', edad: 130), throwsArgumentError);
    expect(borrador().integrantes, isEmpty);
  });

  test('se puede quitar a un integrante agregado por error', () {
    agregar('Ana Torres');
    agregar('Carlos Torres');

    viewModel().quitarIntegrante(borrador().integrantes.first);

    expect(borrador().integrantes.single.nombre, 'Carlos Torres');
  });

  test('el grupo puede elegir varias actividades y desmarcarlas', () {
    viewModel().alternarActividad(Actividad.senderismo);
    viewModel().alternarActividad(Actividad.aves);
    expect(borrador().actividades, {Actividad.senderismo, Actividad.aves});

    viewModel().alternarActividad(Actividad.senderismo);
    expect(borrador().actividades, {Actividad.aves});
  });

  test('hace falta al menos un integrante y una actividad', () {
    agregar('Ana Torres');
    expect(borrador().completo, isFalse);

    viewModel().alternarActividad(Actividad.senderismo);
    expect(borrador().completo, isTrue);
  });

  test('cinco turistas se registran como una visita con un solo QR', () {
    for (final nombre in ['Ana', 'Carlos', 'Lucía', 'Mateo', 'Emma']) {
      agregar(nombre);
    }
    viewModel().alternarActividad(Actividad.senderismo);
    viewModel().alternarActividad(Actividad.fotografia);

    final visita = viewModel().registrar();

    expect(container.read(visitasViewModelProvider), [visita]);
    expect(visita.tamanoGrupo, 5);
    expect(visita.nombreResponsable, 'Ana');
    expect(visita.actividades, {Actividad.senderismo, Actividad.fotografia});
    expect(visita.codigoQr, 'bosqueseco:visita:${visita.id}');
  });

  test('después de registrar, el formulario queda listo para otro grupo', () {
    agregar('Ana Torres');
    viewModel().alternarActividad(Actividad.aves);

    viewModel().registrar();

    expect(borrador().integrantes, isEmpty);
    expect(borrador().actividades, isEmpty);
  });

  test('si falta la actividad no se registra y se conserva lo escrito', () {
    agregar('Ana Torres');

    expect(() => viewModel().registrar(), throwsArgumentError);

    expect(borrador().integrantes, hasLength(1));
    expect(container.read(visitasViewModelProvider), isEmpty);
  });

  group('grupo que llega con reserva (R15)', () {
    // Reserva de demostración: Carmen Seminario, hoy a las 15:00, 4 personas.
    const reservaId = 'r3';

    Reserva? reserva() =>
        container.read(reservasViewModelProvider.notifier).buscar(reservaId);

    void registrarAlGrupo() {
      agregar('Carmen Seminario');
      agregar('Raúl Seminario');
      viewModel().alternarActividad(Actividad.senderismo);
    }

    test(
      'al registrar, la reserva se convierte en el ingreso de la visita',
      () {
        viewModel().atenderReserva(reservaId);
        expect(container.read(reservaEnAtencionProvider)?.id, reservaId);
        registrarAlGrupo();

        final visita = viewModel().registrar();

        expect(visita.reservaId, reservaId);
        expect(reserva()?.estado, EstadoReserva.ingresada);
        expect(reserva()?.visitaId, visita.id);
        // Llegaron 2 de los 4 reservados: se registra a quienes vinieron.
        expect(visita.tamanoGrupo, 2);
        expect(borrador().reservaId, isNull);
        expect(
          container
              .read(agendaReservasProvider)
              .deHoy
              .reservas
              .map((r) => r.id),
          isNot(contains(reservaId)),
        );
      },
    );

    test('lo que ya estaba escrito se conserva al atender la reserva', () {
      agregar('Carmen Seminario');

      viewModel().atenderReserva(reservaId);

      expect(borrador().integrantes, hasLength(1));
    });

    test('quitar la reserva registra al grupo sin ella', () {
      viewModel().atenderReserva(reservaId);
      viewModel().soltarReserva();
      registrarAlGrupo();

      final visita = viewModel().registrar();

      expect(visita.reservaId, isNull);
      expect(reserva()?.pendiente, isTrue);
    });

    test('si la reserva se canceló mientras tanto, el grupo igual se '
        'registra', () {
      viewModel().atenderReserva(reservaId);
      container.read(reservasViewModelProvider.notifier).cancelar(reservaId);
      expect(container.read(reservaEnAtencionProvider), isNull);
      registrarAlGrupo();

      final visita = viewModel().registrar();

      expect(visita.reservaId, isNull);
      expect(reserva()?.estado, EstadoReserva.cancelada);
    });

    test('si falta un dato, la reserva sigue pendiente', () {
      viewModel().atenderReserva(reservaId);
      agregar('Carmen Seminario');

      expect(() => viewModel().registrar(), throwsArgumentError);

      expect(reserva()?.pendiente, isTrue);
      expect(borrador().reservaId, reservaId);
    });
  });

  test('si el grupo acampa, se registra con la salida elegida', () {
    agregar('Rosa Castillo');
    viewModel().alternarActividad(Actividad.campamento);
    final manana = DateTime(2026, 10, 11, 10);
    viewModel().elegirSalida(manana);

    final visita = viewModel().registrar();

    expect(visita.salidaPrevista, manana);
  });
}
