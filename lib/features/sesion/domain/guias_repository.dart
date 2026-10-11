import 'guia.dart';

/// Guías autorizados de cada asociación.
abstract interface class GuiasRepository {
  /// Guías de la asociación, ordenados por nombre. Se leen del celular para
  /// que funcione sin señal; la lista se actualiza cuando hay conexión.
  List<Guia> guiasDe(String asociacionId);
}
