/// Visita (grupo) a la que está vinculado el celular del turista. Se
/// guarda en el celular al escanear el QR del grupo, sin necesitar señal.
abstract interface class VinculoRepository {
  /// Id de la visita vinculada, o `null` si aún no escaneó el QR del grupo.
  String? visitaVinculada();

  Future<void> vincular(String visitaId);
}
