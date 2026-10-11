/// Si el celular tiene red (wifi o datos). En modo avión o en el bosque,
/// no.
abstract interface class RedRepository {
  /// Emite el estado actual y luego cada cambio.
  Stream<bool> hayRed();
}
