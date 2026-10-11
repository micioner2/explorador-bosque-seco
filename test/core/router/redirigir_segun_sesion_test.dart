import 'package:explorador_bosque_seco/core/router/app_router.dart';
import 'package:explorador_bosque_seco/core/router/rutas.dart';
import 'package:explorador_bosque_seco/features/sesion/domain/cuenta_asociacion.dart';
import 'package:explorador_bosque_seco/features/sesion/domain/guia.dart';
import 'package:explorador_bosque_seco/features/sesion/domain/sesion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const cuenta = CuentaAsociacion(
    asociacionId: 'a1',
    nombreAsociacion: 'Bosques de Lancones',
    correo: 'lancones@ejemplo.pe',
  );
  const sinCuenta = Sesion();
  const sinGuia = Sesion(cuenta: cuenta);
  final completa = sinGuia.elegirGuia(
    Guia(id: 'g1', asociacionId: 'a1', nombre: 'Rosa Yarlequé'),
  );

  test('el modo turista nunca pide cuenta', () {
    for (final ruta in [
      Rutas.explorar,
      Rutas.mapa,
      Rutas.pasaporte,
      Rutas.escanear,
      Rutas.ajustes,
    ]) {
      expect(redirigirSegunSesion(sinCuenta, ruta), isNull, reason: ruta);
    }
  });

  test('sin cuenta, el puesto de control lleva al acceso (R11)', () {
    expect(redirigirSegunSesion(sinCuenta, Rutas.asociacionHoy), Rutas.acceso);
    expect(
      redirigirSegunSesion(sinCuenta, Rutas.asociacionRegistrar),
      Rutas.acceso,
    );
    expect(redirigirSegunSesion(sinCuenta, Rutas.accesoGuia), Rutas.acceso);
    expect(redirigirSegunSesion(sinCuenta, Rutas.acceso), isNull);
  });

  test('con cuenta y sin guía, lleva a elegir guía (R12)', () {
    expect(redirigirSegunSesion(sinGuia, Rutas.acceso), Rutas.accesoGuia);
    expect(
      redirigirSegunSesion(sinGuia, Rutas.asociacionRegistrar),
      Rutas.accesoGuia,
    );
    expect(redirigirSegunSesion(sinGuia, Rutas.accesoGuia), isNull);
  });

  test('con cuenta y guía, entra directo al puesto de control', () {
    expect(redirigirSegunSesion(completa, Rutas.acceso), Rutas.asociacionHoy);
    expect(
      redirigirSegunSesion(completa, Rutas.accesoGuia),
      Rutas.asociacionHoy,
    );
    expect(redirigirSegunSesion(completa, Rutas.asociacionReporte), isNull);
  });
}
