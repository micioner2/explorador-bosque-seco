import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/espacio.dart';
import '../domain/espacio_repository.dart';

/// Datos de demostración de El Angolo. Los valores entre corchetes se
/// reemplazan con la información real de la asociación.
class EspacioRepositoryDemo implements EspacioRepository {
  const EspacioRepositoryDemo();

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
        descripcion: '[Descripción de la asociación]',
      ),
      Atractivo(
        id: 'caida',
        nombre: 'Caída de agua',
        descripcion: '[Descripción de la asociación]',
      ),
      Atractivo(
        id: 'venados',
        nombre: 'Avistamiento de venados',
        descripcion: '[Descripción de la asociación]',
      ),
    ],
    servicios: [
      Servicio(
        id: 'guiado-1',
        tipo: TipoServicio.guiado,
        nombre: 'Guiado comunitario',
        whatsapp: '[número]',
        tarifaReferencial: 'Desde S/ [tarifa] por grupo',
      ),
      Servicio(
        id: 'almuerzo-1',
        tipo: TipoServicio.alimentacion,
        nombre: 'Almuerzo campestre',
        whatsapp: '[número]',
        tarifaReferencial: 'Desde S/ [tarifa] por persona',
      ),
    ],
  );
}

/// Punto único donde se elige la implementación del repositorio.
final espacioRepositoryProvider = Provider<EspacioRepository>(
  (ref) => const EspacioRepositoryDemo(),
);
