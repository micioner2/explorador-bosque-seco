import '../../mapa/domain/ruta.dart';

/// Lo que pasó al escanear un QR, para mostrarlo al turista de inmediato.
sealed class ResultadoEscaneo {
  const ResultadoEscaneo();
}

/// Se leyó el QR del grupo: el celular quedó vinculado a la visita.
/// [yaEstaba] es `true` si ya estaba vinculado a ese mismo grupo.
final class GrupoVinculado extends ResultadoEscaneo {
  const GrupoVinculado({required this.yaEstaba});

  final bool yaEstaba;
}

/// Punto nuevo para el grupo: ganó su sello (pendiente de sincronizar).
final class SelloGanado extends ResultadoEscaneo {
  const SelloGanado(this.punto);

  final PuntoRuta punto;
}

/// El grupo ya tenía el sello de este punto: no suma de nuevo (R1).
final class SelloRepetido extends ResultadoEscaneo {
  const SelloRepetido(this.punto);

  final PuntoRuta punto;
}

/// Es un punto de la ruta, pero el celular aún no está vinculado a un
/// grupo: primero hay que escanear el QR que muestra el guía.
final class FaltaGrupo extends ResultadoEscaneo {
  const FaltaGrupo(this.punto);

  final PuntoRuta punto;
}

/// En el puesto de control se leyó un cupón de canje.
final class CuponLeido extends ResultadoEscaneo {
  const CuponLeido({
    required this.nombreProducto,
    required this.valido,
    required this.porcentaje,
  });

  final String nombreProducto;
  final int porcentaje;

  /// `false` si ya se había usado (R18).
  final bool valido;
}

/// El turista escaneó un cupón: es para mostrarlo en la tienda.
final class CuponDelTurista extends ResultadoEscaneo {
  const CuponDelTurista();
}

/// Parece el código de un punto, pero no es de esta ruta.
final class PuntoAjeno extends ResultadoEscaneo {
  const PuntoAjeno();
}

/// El QR no es de la app.
final class QrAjeno extends ResultadoEscaneo {
  const QrAjeno();
}
