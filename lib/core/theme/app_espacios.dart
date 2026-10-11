/// Medidas compartidas para que todas las pantallas respiren igual.
abstract final class AppEspacios {
  static const xs = 4.0;
  static const s = 8.0;
  static const m = 12.0;
  static const l = 16.0;
  static const xl = 24.0;

  /// Esquinas de tarjetas y paneles.
  static const radio = 16.0;

  /// Esquinas de botones, campos y avisos.
  static const radioChico = 12.0;

  /// Lado mínimo de todo lo que se toca (uso al aire libre, con el pulgar).
  static const objetivoTactil = 48.0;

  /// Espacio al final de las listas del modo turista para que el botón
  /// flotante de escanear no tape el último elemento.
  static const bajoBotonFlotante = 120.0;
}
