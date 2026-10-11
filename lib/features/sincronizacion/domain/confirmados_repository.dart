/// Ids de los registros que el servidor ya aceptó, por colección
/// (`visitas`, `cierres`). Lo que no está aquí sigue pendiente.
abstract interface class ConfirmadosRepository {
  Set<String> confirmados(String coleccion);

  Future<void> confirmar(String coleccion, Iterable<String> ids);
}
