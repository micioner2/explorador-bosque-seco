import 'package:explorador_bosque_seco/features/sesion/domain/cuenta_asociacion.dart';
import 'package:explorador_bosque_seco/features/sesion/domain/guia.dart';
import 'package:explorador_bosque_seco/features/sesion/domain/sesion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const cuenta = CuentaAsociacion(
    asociacionId: 'angolo',
    nombreAsociacion: 'Coto de Caza El Angolo',
    correo: 'angolo@ejemplo.pe',
  );
  final maria = Guia(id: 'g1', asociacionId: 'angolo', nombre: 'María Quispe');

  group('Guia', () {
    test('quita los espacios sobrantes del nombre', () {
      final guia = Guia(id: 'g1', asociacionId: 'a', nombre: '  Juan Chunga ');

      expect(guia.nombre, 'Juan Chunga');
    });

    test('no acepta un nombre vacío', () {
      expect(
        () => Guia(id: 'g1', asociacionId: 'a', nombre: '   '),
        throwsArgumentError,
      );
    });
  });

  group('Sesion', () {
    test('sin cuenta no está iniciada ni lista para registrar', () {
      const sesion = Sesion();

      expect(sesion.iniciada, isFalse);
      expect(sesion.listaParaRegistrar, isFalse);
    });

    test('con cuenta pero sin guía, aún no se puede registrar (R12)', () {
      const sesion = Sesion(cuenta: cuenta);

      expect(sesion.iniciada, isTrue);
      expect(sesion.listaParaRegistrar, isFalse);
      expect(sesion.quienRegistra, throwsStateError);
    });

    test('al elegir guía, los registros quedan a su nombre', () {
      final sesion = const Sesion(cuenta: cuenta).elegirGuia(maria);

      expect(sesion.listaParaRegistrar, isTrue);
      final (cuenta: deLaCuenta, :guia) = sesion.quienRegistra();
      expect(deLaCuenta, cuenta);
      expect(guia, maria);
    });

    test('no se elige guía sin entrar antes con la cuenta (R11)', () {
      expect(() => const Sesion().elegirGuia(maria), throwsStateError);
    });

    test('no se puede elegir un guía de otra asociación', () {
      final deOtra = Guia(id: 'g9', asociacionId: 'lancones', nombre: 'Ana');

      expect(
        () => const Sesion(cuenta: cuenta).elegirGuia(deOtra),
        throwsArgumentError,
      );
    });

    test('cambiar de guía conserva la cuenta abierta', () {
      final sesion = const Sesion(
        cuenta: cuenta,
      ).elegirGuia(maria).soltarGuia();

      expect(sesion.cuenta, cuenta);
      expect(sesion.guia, isNull);
    });
  });
}
