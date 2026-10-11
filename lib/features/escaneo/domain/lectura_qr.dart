/// Qué es un QR leído por la cámara. Un solo botón "Escanear QR" sirve
/// para todo: la app reconoce si es el QR del grupo o el de un punto.
///
/// Formatos (texto del QR):
/// - Grupo: `bosqueseco:visita:<id de la visita>` (lo muestra el guía).
/// - Punto de la ruta: `bosqueseco:punto:<id del punto>` (cartel impreso).
/// - Cupón de canje: `bosqueseco:cupon:<id>:<producto>:<porcentaje>` (lo
///   muestra el turista en la tienda).
sealed class LecturaQr {
  const LecturaQr();

  /// Interpreta el texto de un QR. También acepta el código del punto
  /// escrito a mano ("mirador"), por si la cámara no logra leer el cartel.
  factory LecturaQr.desde(String texto) {
    final limpio = texto.trim();
    final partes = limpio.split(':');
    if (partes.length == 5 &&
        partes[0].toLowerCase() == prefijo &&
        partes[1].toLowerCase() == 'cupon') {
      final porcentaje = int.tryParse(partes[4]);
      if (partes[2].isNotEmpty && partes[3].isNotEmpty && porcentaje != null) {
        return QrDeCupon(
          id: partes[2],
          productoId: partes[3],
          porcentaje: porcentaje,
        );
      }
    }
    if (partes.length == 3 && partes[0].toLowerCase() == prefijo) {
      final id = partes[2].trim();
      if (id.isNotEmpty) {
        switch (partes[1].toLowerCase()) {
          case 'visita':
            return QrDeGrupo(id);
          case 'punto':
            return QrDePunto(id.toLowerCase());
        }
      }
    }
    if (RegExp(r'^[a-zA-Z][a-zA-Z0-9_-]{1,40}$').hasMatch(limpio)) {
      return QrDePunto(limpio.toLowerCase());
    }
    return const QrDesconocido();
  }

  static const prefijo = 'bosqueseco';

  /// Texto que lleva el QR impreso de un punto de la ruta.
  static String textoDePunto(String puntoId) => '$prefijo:punto:$puntoId';
}

/// QR del grupo: vincula este celular con la visita registrada en el
/// puesto de control.
final class QrDeGrupo extends LecturaQr {
  const QrDeGrupo(this.visitaId);

  final String visitaId;
}

/// QR de un punto turístico: da el sello de ese punto.
final class QrDePunto extends LecturaQr {
  const QrDePunto(this.puntoId);

  final String puntoId;
}

/// Cupón de canje del turista: se valida en el puesto de control.
final class QrDeCupon extends LecturaQr {
  const QrDeCupon({
    required this.id,
    required this.productoId,
    required this.porcentaje,
  });

  final String id;
  final String productoId;
  final int porcentaje;
}

/// Un QR que no es de la app (un enlace, un producto...).
final class QrDesconocido extends LecturaQr {
  const QrDesconocido();
}
