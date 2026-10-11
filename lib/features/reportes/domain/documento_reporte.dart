import 'dart:typed_data';

/// Una cifra destacada del reporte ("Visitantes: 9").
class CifraReporte {
  const CifraReporte(this.etiqueta, this.valor);

  final String etiqueta;
  final int valor;
}

/// Una fila de una sección: etiqueta, cantidad y un detalle opcional.
class FilaReporte {
  const FilaReporte(this.etiqueta, this.cantidad, {this.detalle});

  final String etiqueta;
  final int cantidad;
  final String? detalle;
}

/// Bloque del reporte con su título y sus filas (por ejemplo, procedencia).
class SeccionReporte {
  SeccionReporte({required this.titulo, required Iterable<FilaReporte> filas})
    : filas = List.unmodifiable(filas);

  final String titulo;
  final List<FilaReporte> filas;

  /// Total de la sección, para dibujar las barras en proporción.
  int get total => filas.fold(0, (suma, fila) => suma + fila.cantidad);
}

/// Reporte del día listo para imprimir: textos ya traducidos y cifras ya
/// calculadas por las reglas (`ReporteDiario`, `CierreDia`). Quien lo
/// convierte en PDF solo lo dibuja (criterio C3 de AIDER).
class DocumentoReporte {
  DocumentoReporte({
    required this.marca,
    required this.titulo,
    required Iterable<String> encabezado,
    required Iterable<CifraReporte> cifras,
    required Iterable<SeccionReporte> secciones,
    required this.textoSinDatos,
    required this.nota,
    required this.nombreArchivo,
    this.alerta,
  }) : encabezado = List.unmodifiable(encabezado),
       cifras = List.unmodifiable(cifras),
       secciones = List.unmodifiable(secciones);

  /// Logo de texto, por ejemplo "Bosque Seco · Asociación".
  final String marca;
  final String titulo;

  /// Líneas bajo el título: asociación, fecha y quién cerró el día.
  final List<String> encabezado;
  final List<CifraReporte> cifras;
  final List<SeccionReporte> secciones;

  /// Aviso destacado (por ejemplo, grupos sin salida marcada).
  final String? alerta;

  /// Texto para una sección sin filas.
  final String textoSinDatos;

  /// Pie de página: de dónde salió el reporte.
  final String nota;
  final String nombreArchivo;
}

/// Convierte el reporte en un PDF. Funciona sin señal.
abstract interface class GeneradorReporte {
  Future<Uint8List> generar(DocumentoReporte documento);
}

/// Abre el menú del celular para compartir o guardar un archivo (WhatsApp,
/// Drive, Descargas). Devuelve `false` si la persona lo cerró sin elegir.
abstract interface class CompartirArchivo {
  Future<bool> compartir(Uint8List bytes, {required String nombreArchivo});
}
