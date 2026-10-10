import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/pasaporte.dart';
import '../../domain/producto.dart';
import '../view_models/pasaporte_view_model.dart';

/// Pasaporte del turista: puntos ganados y canje en la tienda comunal.
class PasaportePage extends ConsumerWidget {
  const PasaportePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pasaporte = ref.watch(pasaporteViewModelProvider);
    final productos = ref.watch(productosProvider);

    void canjear(Producto producto) {
      final mensajero = ScaffoldMessenger.of(context);
      try {
        ref.read(pasaporteViewModelProvider.notifier).canjear(producto);
        mensajero.showSnackBar(
          SnackBar(content: Text('Cupón generado: ${producto.nombre}')),
        );
      } on CanjeInvalido catch (error) {
        mensajero.showSnackBar(SnackBar(content: Text(error.mensaje)));
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mi pasaporte')),
      body: ListView(
        children: [
          _ResumenPuntos(pasaporte: pasaporte),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'Canjea en la tienda de la comunidad',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.verdeOscuro,
              ),
            ),
          ),
          for (final producto in productos)
            _TarjetaProducto(
              producto: producto,
              pasaporte: pasaporte,
              onCanjear: () => canjear(producto),
            ),
        ],
      ),
    );
  }
}

class _ResumenPuntos extends StatelessWidget {
  const _ResumenPuntos({required this.pasaporte});

  final Pasaporte pasaporte;

  @override
  Widget build(BuildContext context) {
    final total = pasaporte.puntosConfirmados + pasaporte.puntosPendientes;
    return Container(
      color: AppColors.verdeOscuro,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$total',
            style: const TextStyle(
              fontSize: 52,
              height: 1,
              fontWeight: FontWeight.w700,
              color: AppColors.amarilloCrema,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'puntos',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  '${pasaporte.puntosConfirmados} confirmados · '
                  '${pasaporte.puntosPendientes} pendientes',
                  style: const TextStyle(color: Colors.white70),
                ),
                if (pasaporte.puntosCanjeados > 0)
                  Text(
                    '${pasaporte.puntosCanjeados} ya canjeados',
                    style: const TextStyle(color: Colors.white70),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaProducto extends StatelessWidget {
  const _TarjetaProducto({
    required this.producto,
    required this.pasaporte,
    required this.onCanjear,
  });

  final Producto producto;
  final Pasaporte pasaporte;
  final VoidCallback onCanjear;

  @override
  Widget build(BuildContext context) {
    final puede = pasaporte.puedeCanjear(producto);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: ListTile(
        title: Text(
          producto.nombre,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          puede
              ? '${producto.puntosRequeridos} puntos = '
                    '${producto.porcentajeDescuento}% de descuento'
              : 'Te faltan ${pasaporte.puntosFaltantes(producto)} puntos',
        ),
        trailing: puede
            ? FilledButton(onPressed: onCanjear, child: const Text('Canjear'))
            : null,
      ),
    );
  }
}
