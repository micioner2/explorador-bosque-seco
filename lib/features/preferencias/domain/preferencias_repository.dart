import 'preferencias.dart';

/// Contrato de acceso a las preferencias guardadas en el celular.
abstract interface class PreferenciasRepository {
  Preferencias leer();

  Future<void> guardar(Preferencias preferencias);
}
