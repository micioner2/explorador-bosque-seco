import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/espacio.dart';
import '../domain/espacio_repository.dart';

/// Datos de demostración de El Angolo: textos, tarifas e imágenes de
/// ejemplo hasta que la asociación cargue los suyos en el portal web. Las
/// imágenes de `assets/fotos/` son ilustraciones: se reemplazan por fotos
/// reales con el mismo nombre.
class EspacioRepositoryDemo implements EspacioRepository {
  const EspacioRepositoryDemo();

  /// WhatsApp de los servicios de demostración. Para la presentación, pon
  /// el celular de alguien del equipo: el jurado verá abrirse el chat.
  static const whatsappDemo = '+51 999 999 999';

  @override
  Espacio espacioActual() => const Espacio(
    id: 'el-angolo',
    nombre: 'Coto de Caza El Angolo',
    ubicacion: 'Piura · Entrada por Máncora',
    mediosPago: ['Efectivo', 'Yape'],
    senal: 'Solo en el pueblo',
    acceso: '1 h de trocha',
    atractivos: [
      Atractivo(
        id: 'pozas',
        nombre: 'Pozas de agua',
        descripcion:
            'Pozas naturales entre algarrobos y palos santos, donde '
            'beben venados y aves al amanecer.',
        foto: 'assets/fotos/pozas.jpg',
      ),
      Atractivo(
        id: 'caida',
        nombre: 'Caída de agua',
        descripcion:
            'En temporada de lluvias (enero a abril) el agua cae entre '
            'rocas. Lleva calzado que no resbale.',
        foto: 'assets/fotos/caida.jpg',
      ),
      Atractivo(
        id: 'mirador',
        nombre: 'Mirador',
        descripcion:
            'Vista del bosque seco hasta los cerros de Amotape. Ideal '
            'para fotos al atardecer.',
        foto: 'assets/fotos/mirador.jpg',
      ),
      Atractivo(
        id: 'venados',
        nombre: 'Avistamiento de venados',
        descripcion:
            'Zona tranquila para ver venados de cola blanca. Camina en '
            'silencio y sigue al guía.',
        foto: 'assets/fotos/venados.jpg',
      ),
    ],
    servicios: [
      Servicio(
        id: 'guiado-1',
        tipo: TipoServicio.guiado,
        nombre: 'Guiado comunitario',
        whatsapp: whatsappDemo,
        tarifaReferencial: 'Desde S/ 50 por grupo',
      ),
      Servicio(
        id: 'aves-1',
        tipo: TipoServicio.guiado,
        nombre: 'Salida de aves al amanecer',
        whatsapp: whatsappDemo,
        tarifaReferencial: 'Desde S/ 80 por grupo',
      ),
      Servicio(
        id: 'almuerzo-1',
        tipo: TipoServicio.alimentacion,
        nombre: 'Almuerzo campestre (seco de cabrito)',
        whatsapp: whatsappDemo,
        tarifaReferencial: 'Desde S/ 20 por persona',
      ),
      Servicio(
        id: 'hospedaje-1',
        tipo: TipoServicio.hospedaje,
        nombre: 'Zona de campamento con baño',
        whatsapp: whatsappDemo,
        tarifaReferencial: 'Desde S/ 15 por carpa',
      ),
      Servicio(
        id: 'transporte-1',
        tipo: TipoServicio.transporte,
        nombre: 'Mototaxi desde Máncora',
        whatsapp: whatsappDemo,
        tarifaReferencial: 'Desde S/ 60 ida y vuelta',
      ),
    ],
  );
}

/// Punto único donde se elige la implementación del repositorio.
final espacioRepositoryProvider = Provider<EspacioRepository>(
  (ref) => const EspacioRepositoryDemo(),
);
