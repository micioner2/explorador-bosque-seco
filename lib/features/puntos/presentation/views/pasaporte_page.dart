import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_espacios.dart';
import '../../../../core/theme/colores_app.dart';
import '../../../../shared/widgets/acciones_barra.dart';
import '../../../../shared/widgets/dialogo_confirmar.dart';
import '../../../../shared/widgets/encabezado.dart';
import '../../../../shared/widgets/etiqueta_estado.dart';
import '../../../../shared/widgets/icono_circular.dart';
import '../../../../shared/widgets/titulo_seccion.dart';
import '../../../mapa/domain/progreso_ruta.dart';
import '../../../mapa/presentation/view_models/mapa_view_model.dart';
import '../../domain/pasaporte.dart';
import '../../domain/producto.dart';
import '../view_models/pasaporte_view_model.dart';

/// Pasaporte del turista: puntos ganados, sellos de la ruta y canje en la
/// tienda comunal.
class PasaportePage extends ConsumerWidget {
  const PasaportePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final pasaporte = ref.watch(pasaporteViewModelProvider);
    final productos = ref.watch(productosProvider);
    final progreso = ref.watch(mapaViewModelProvider);

    Future<void> canjear(Producto producto) async {
      final mensajero = ScaffoldMessenger.of(context);
      final aceptado = await confirmar(
        context,
        titulo: l10n.canjeConfirmarTitulo,
        detalle: l10n.canjeConfirmarDetalle(
          producto.puntosRequeridos,
          producto.porcentajeDescuento,
          producto.nombre,
        ),
        accion: l10n.canjear,
      );
      if (!aceptado || !context.mounted) return;
      try {
        ref.read(pasaporteViewModelProvider.notifier).canjear(producto);
        mensajero.showSnackBar(
          SnackBar(content: Text(l10n.canjeCupon(producto.nombre))),
        );
      } on CanjeInvalido {
        mensajero.showSnackBar(
          SnackBar(
            content: Text(
              l10n.productoFaltan(pasaporte.puntosFaltantes(producto)),
            ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pasaporteTitulo),
        actions: const [BotonAjustes()],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppEspacios.bajoBotonFlotante),
        children: [
          _ResumenPuntos(pasaporte: pasaporte),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppEspacios.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TituloSeccion(l10n.pasaporteSellos),
                _Sellos(progreso: progreso),
                TituloSeccion(l10n.pasaporteCanje),
                Padding(
                  padding: const EdgeInsets.only(bottom: AppEspacios.m),
                  child: Text(
                    l10n.pasaporteDisponibles(pasaporte.puntosDisponibles),
                    style: context.textos.bodyMedium?.copyWith(
                      color: context.esquema.onSurfaceVariant,
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
          ),
        ],
      ),
    );
  }
}

/// Total de puntos y cuántos están confirmados o esperando señal.
class _ResumenPuntos extends StatelessWidget {
  const _ResumenPuntos({required this.pasaporte});

  final Pasaporte pasaporte;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textos = context.textos;
    final frente = context.colores.sobreEncabezado;
    final total = pasaporte.puntosConfirmados + pasaporte.puntosPendientes;

    return Encabezado(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MergeSemantics(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$total',
                  style: textos.displayMedium?.copyWith(
                    color: frente,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                const SizedBox(width: AppEspacios.s),
                Flexible(
                  child: Text(
                    l10n.pasaportePuntos(total),
                    style: textos.titleMedium?.copyWith(color: frente),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppEspacios.m),
          Wrap(
            spacing: AppEspacios.s,
            runSpacing: AppEspacios.s,
            children: [
              _Pastilla(
                icono: Icons.check_circle_outline,
                texto: l10n.pasaporteConfirmados(pasaporte.puntosConfirmados),
              ),
              if (pasaporte.puntosPendientes > 0)
                _Pastilla(
                  icono: Icons.sync,
                  texto: l10n.pasaportePendientes(pasaporte.puntosPendientes),
                ),
              if (pasaporte.puntosCanjeados > 0)
                _Pastilla(
                  icono: Icons.redeem,
                  texto: l10n.pasaporteCanjeados(pasaporte.puntosCanjeados),
                ),
            ],
          ),
          if (pasaporte.puntosPendientes > 0) ...[
            const SizedBox(height: AppEspacios.m),
            Text(
              l10n.pasaportePendientesNota,
              style: textos.bodyMedium?.copyWith(color: frente),
            ),
          ],
        ],
      ),
    );
  }
}

/// Dato corto sobre la cabecera ("2 confirmados").
class _Pastilla extends StatelessWidget {
  const _Pastilla({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final frente = context.colores.sobreEncabezado;

    return Container(
      decoration: BoxDecoration(
        color: frente.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 16, color: frente),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              texto,
              style: context.textos.labelMedium?.copyWith(color: frente),
            ),
          ),
        ],
      ),
    );
  }
}

/// Los sellos de la ruta: conseguidos, pendientes de sincronizar y por
/// visitar.
class _Sellos extends StatelessWidget {
  const _Sellos({required this.progreso});

  final ProgresoRuta progreso;

  @override
  Widget build(BuildContext context) {
    // Con letra grande caben menos sellos por fila.
    final columnas = MediaQuery.textScalerOf(context).scale(10) > 13 ? 2 : 3;

    return LayoutBuilder(
      builder: (context, limites) {
        const separacion = AppEspacios.m;
        final ancho =
            (limites.maxWidth - separacion * (columnas - 1)) / columnas;
        return Wrap(
          spacing: separacion,
          runSpacing: AppEspacios.l,
          children: [
            for (final punto in progreso.puntos)
              SizedBox(
                width: ancho.floorToDouble(),
                child: _Sello(punto: punto),
              ),
          ],
        );
      },
    );
  }
}

class _Sello extends StatelessWidget {
  const _Sello({required this.punto});

  final PuntoEnRuta punto;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final esquema = context.esquema;
    final colores = context.colores;
    final textos = context.textos;
    final (fondo, frente, borde, estado) = switch (punto.estado) {
      EstadoPunto.confirmado => (
        esquema.primary,
        esquema.onPrimary,
        esquema.primary,
        l10n.selloConfirmado,
      ),
      EstadoPunto.pendiente => (
        colores.aviso,
        colores.sobreAviso,
        colores.sobreAviso,
        l10n.selloPendiente,
      ),
      EstadoPunto.porVisitar => (
        esquema.surface,
        esquema.onSurfaceVariant,
        esquema.outline,
        l10n.selloPorVisitar,
      ),
    };

    return MergeSemantics(
      child: Column(
        children: [
          ExcludeSemantics(
            child: Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: fondo,
                shape: BoxShape.circle,
                border: Border.all(color: borde, width: 2),
              ),
              child: switch (punto.estado) {
                EstadoPunto.confirmado => Icon(
                  Icons.verified,
                  size: 30,
                  color: frente,
                ),
                EstadoPunto.pendiente => Icon(
                  Icons.sync,
                  size: 28,
                  color: frente,
                ),
                EstadoPunto.porVisitar => Text(
                  '${punto.orden}',
                  style: textos.titleLarge?.copyWith(color: frente),
                  textScaler: TextScaler.noScaling,
                ),
              },
            ),
          ),
          const SizedBox(height: AppEspacios.s),
          Text(
            punto.punto.nombre,
            textAlign: TextAlign.center,
            style: textos.labelMedium?.copyWith(color: esquema.onSurface),
          ),
          Text(
            estado,
            textAlign: TextAlign.center,
            style: textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant),
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
    final l10n = context.l10n;
    final esquema = context.esquema;
    final textos = context.textos;
    final puede = pasaporte.puedeCanjear(producto);
    final faltan = pasaporte.puntosFaltantes(producto);
    final avance =
        (producto.puntosRequeridos - faltan) / producto.puntosRequeridos;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppEspacios.m),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppEspacios.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const IconoCircular(Icons.local_mall_outlined),
                  const SizedBox(width: AppEspacios.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(producto.nombre, style: textos.titleSmall),
                        const SizedBox(height: 2),
                        Text(
                          l10n.productoOferta(
                            producto.puntosRequeridos,
                            producto.porcentajeDescuento,
                          ),
                          style: textos.bodyMedium?.copyWith(
                            color: esquema.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppEspacios.s),
                  ExcludeSemantics(
                    child: EtiquetaEstado(
                      texto: '-${producto.porcentajeDescuento}%',
                      tono: TonoEtiqueta.acento,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppEspacios.m),
              if (puede)
                FilledButton(onPressed: onCanjear, child: Text(l10n.canjear))
              else ...[
                LinearProgressIndicator(
                  value: avance,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                  semanticsLabel: l10n.productoFaltan(faltan),
                ),
                const SizedBox(height: AppEspacios.s),
                ExcludeSemantics(
                  child: Text(
                    l10n.productoFaltan(faltan),
                    style: textos.labelMedium?.copyWith(
                      color: esquema.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
