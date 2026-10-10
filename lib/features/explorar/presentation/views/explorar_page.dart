import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/rutas.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/tarjeta_dato.dart';
import '../../domain/espacio.dart';
import '../view_models/explorar_view_model.dart';

/// Pantalla principal del turista: información práctica, atractivos y
/// servicios de la comunidad.
class ExplorarPage extends ConsumerWidget {
  const ExplorarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final espacio = ref.watch(explorarViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(espacio.nombre),
        actions: [
          IconButton(
            tooltip: 'Modo asociación',
            icon: const Icon(Icons.storefront_outlined),
            onPressed: () => context.go(Rutas.asociacionHoy),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              espacio.ubicacion,
              style: const TextStyle(color: AppColors.textoSecundario),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.6,
              children: [
                TarjetaDato(
                  etiqueta: 'Pago',
                  valor: espacio.mediosPago.join(' · '),
                ),
                TarjetaDato(etiqueta: 'Señal', valor: espacio.senal),
                TarjetaDato(etiqueta: 'Acceso', valor: espacio.acceso),
                const TarjetaDato(etiqueta: 'Ingreso', valor: 'Con guía'),
              ],
            ),
          ),
          const _Titulo('Atractivos'),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: espacio.atractivos.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) =>
                  _TarjetaAtractivo(atractivo: espacio.atractivos[i]),
            ),
          ),
          const _Titulo('Servicios de la comunidad'),
          for (final servicio in espacio.servicios)
            _TarjetaServicio(servicio: servicio),
        ],
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.verdeOscuro,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TarjetaAtractivo extends StatelessWidget {
  const _TarjetaAtractivo({required this.atractivo});

  final Atractivo atractivo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              color: AppColors.verdeOscuro,
              alignment: Alignment.center,
              child: const Icon(Icons.landscape, color: Colors.white70),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    atractivo.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const Text(
                    '+1 punto',
                    style: TextStyle(color: AppColors.marronTierra),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaServicio extends StatelessWidget {
  const _TarjetaServicio({required this.servicio});

  final Servicio servicio;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: ListTile(
        title: Text(
          servicio.nombre,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(servicio.tarifaReferencial ?? servicio.tipo.etiqueta),
        trailing: FilledButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('WhatsApp: ${servicio.whatsapp}')),
          ),
          icon: const Icon(Icons.chat_outlined),
          label: const Text('WhatsApp'),
        ),
      ),
    );
  }
}
