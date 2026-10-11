import 'package:explorador_bosque_seco/features/visitas/domain/visita.dart';
import 'package:flutter_test/flutter_test.dart';

Visitante persona({String nombre = 'Ana Torres', int edad = 34}) => Visitante(
  nombre: nombre,
  documento: '40000000',
  edad: edad,
  procedencia: Procedencia.piura,
);

Visita visita({
  List<Visitante>? integrantes,
  Iterable<Actividad> actividades = const [Actividad.senderismo],
  DateTime? entrada,
  DateTime? salidaPrevista,
}) {
  final e = entrada ?? DateTime(2026, 10, 10, 8);
  return Visita(
    id: 'v1',
    asociacionId: 'a1',
    integrantes: integrantes ?? [persona()],
    actividades: actividades,
    fechaEntrada: e,
    salidaPrevista: salidaPrevista ?? e.add(const Duration(hours: 8)),
  );
}

void main() {
  group('Validaciones de cada integrante', () {
    test('rechaza nombre vacío', () {
      expect(() => persona(nombre: '  '), throwsArgumentError);
    });

    test('rechaza edad fuera de rango', () {
      expect(() => persona(edad: -1), throwsArgumentError);
      expect(() => persona(edad: 150), throwsArgumentError);
    });

    test('quita los espacios sobrantes del nombre', () {
      expect(persona(nombre: '  Ana Torres ').nombre, 'Ana Torres');
    });

    test('un visitante peruano se identifica con su DNI de 8 dígitos', () {
      Visitante conDni(String dni) => Visitante(
        nombre: 'Ana Torres',
        documento: dni,
        edad: 34,
        procedencia: Procedencia.lima,
      );

      expect(conDni('4512 0300').documento, '45120300');
      expect(() => conDni(''), throwsArgumentError);
      expect(() => conDni('4512030'), throwsArgumentError);
      expect(() => conDni('AB120300'), throwsArgumentError);
    });

    test('quien viene del extranjero da su pasaporte y su país', () {
      final emma = Visitante(
        nombre: 'Emma Schmidt',
        documento: 'c01x-00t47',
        edad: 31,
        procedencia: Procedencia.extranjero,
        pais: ' Alemania ',
      );

      expect(emma.documento, 'C01X00T47');
      expect(emma.pais, 'Alemania');
      expect(
        () => Visitante(
          nombre: 'Emma Schmidt',
          documento: 'C01X00T47',
          edad: 31,
          procedencia: Procedencia.extranjero,
        ),
        throwsArgumentError,
      );
    });

    test('un visitante peruano no guarda país', () {
      expect(persona().pais, isNull);
    });

    test('revisar el documento explica qué está mal', () {
      expect(
        Visitante.revisarDocumento(' ', Procedencia.piura),
        ProblemaDocumento.vacio,
      );
      expect(
        Visitante.revisarDocumento('123', Procedencia.piura),
        ProblemaDocumento.dniInvalido,
      );
      expect(
        Visitante.revisarDocumento('12', Procedencia.extranjero),
        ProblemaDocumento.documentoInvalido,
      );
      expect(
        Visitante.revisarDocumento('45120300', Procedencia.otraRegion),
        isNull,
      );
    });
  });

  group('Validaciones del grupo', () {
    test('rechaza un grupo sin integrantes', () {
      expect(() => visita(integrantes: const []), throwsArgumentError);
    });

    test('rechaza un grupo sin actividades', () {
      expect(() => visita(actividades: const []), throwsArgumentError);
    });

    test('la salida prevista debe ser posterior a la entrada', () {
      final entrada = DateTime(2026, 10, 10, 8);
      expect(
        () => visita(entrada: entrada, salidaPrevista: entrada),
        throwsArgumentError,
      );
    });
  });

  group('Grupo con un solo QR', () {
    final grupo = visita(
      integrantes: [
        persona(nombre: 'Ana Torres'),
        persona(nombre: 'Carlos Torres', edad: 36),
        persona(nombre: 'Lucía Torres', edad: 12),
      ],
      actividades: const [Actividad.senderismo, Actividad.aves],
    );

    test('el tamaño del grupo es la cantidad de integrantes', () {
      expect(grupo.tamanoGrupo, 3);
    });

    test('el primer integrante es el responsable', () {
      expect(grupo.nombreResponsable, 'Ana Torres');
    });

    test('el grupo puede hacer varias actividades', () {
      expect(grupo.actividades, {Actividad.senderismo, Actividad.aves});
    });

    test('elegir dos veces la misma actividad la cuenta una sola vez', () {
      final repetida = visita(
        actividades: const [Actividad.aves, Actividad.aves],
      );

      expect(repetida.actividades, hasLength(1));
    });

    test('todo el grupo comparte un único QR, que identifica a la visita', () {
      expect(grupo.codigoQr, 'bosqueseco:visita:v1');
    });

    test('los integrantes no se pueden modificar después de registrar', () {
      expect(() => grupo.integrantes.add(persona()), throwsUnsupportedError);
      expect(
        () => grupo.actividades.add(Actividad.campamento),
        throwsUnsupportedError,
      );
    });

    test('al marcar la salida se conservan integrantes y actividades', () {
      final salio = grupo.marcarSalida(DateTime(2026, 10, 10, 15));

      expect(salio.tamanoGrupo, 3);
      expect(salio.actividades, grupo.actividades);
      expect(salio.codigoQr, grupo.codigoQr);
    });
  });

  group('Alerta "sigue dentro"', () {
    final v = visita(
      entrada: DateTime(2026, 10, 10, 8),
      salidaPrevista: DateTime(2026, 10, 10, 16),
    );

    test('no alerta antes de la hora de salida', () {
      expect(v.sigueDentro(DateTime(2026, 10, 10, 15)), isFalse);
    });

    test('alerta si pasó la hora de salida y no marcó salida', () {
      expect(v.sigueDentro(DateTime(2026, 10, 10, 17)), isTrue);
    });

    test('no alerta si ya marcó su salida', () {
      final salio = v.marcarSalida(DateTime(2026, 10, 10, 15, 30));
      expect(salio.sigueDentro(DateTime(2026, 10, 10, 17)), isFalse);
    });

    test('no se puede marcar la salida dos veces', () {
      final salio = v.marcarSalida(DateTime(2026, 10, 10, 15));
      expect(
        () => salio.marcarSalida(DateTime(2026, 10, 10, 16)),
        throwsStateError,
      );
    });
  });
}
