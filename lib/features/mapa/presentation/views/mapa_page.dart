import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/aviso_sin_senal.dart';

/// Mapa de la ruta con la ubicación del turista.
///
/// Siguiente paso: integrar `flutter_map` con las teselas de la zona
/// incluidas en la app y la ruta en GeoJSON, para que funcione sin señal.
class MapaPage extends StatelessWidget {
  const MapaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ruta de las Pozas')),
      body: Column(
        children: [
          const AvisoSinSenal(),
          Expanded(
            child: Container(
              color: const Color(0xFFEEF1E4),
              alignment: Alignment.center,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_outlined, size: 56, color: AppColors.verdeOscuro),
                  SizedBox(height: 8),
                  Text('Mapa sin señal'),
                ],
              ),
            ),
          ),
          const _ResumenRuta(),
        ],
      ),
    );
  }
}

class _ResumenRuta extends StatelessWidget {
  const _ResumenRuta();

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Siguiente punto',
                    style: TextStyle(color: AppColors.textoSecundario),
                  ),
                  Text(
                    '3 · Caída de agua',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  Text('Faltan 1,2 km · unos 25 min'),
                ],
              ),
            ),
            Text('2 de 5'),
          ],
        ),
      ),
    );
  }
}
