import 'guia.dart';

/// Recuerda en el celular qué guía de cada asociación lo usó por última
/// vez, para ofrecerle "Continuar como…" al abrir la app. Funciona sin
/// señal.
abstract interface class UltimoGuiaRepository {
  /// Id del último guía de la asociación, o `null` si nadie entró aún.
  String? ultimoGuiaId(String asociacionId);

  Future<void> recordar(Guia guia);
}
