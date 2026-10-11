import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/etiquetas_dominio.dart';
import '../../../../core/l10n/formato.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/router/rutas.dart';
import '../../../../core/theme/app_espacios.dart';
import '../../../../core/theme/colores_app.dart';
import '../../../../shared/widgets/acciones_barra.dart';
import '../../../../shared/widgets/encabezado.dart';
import '../../../../shared/widgets/etiqueta_estado.dart';
import '../../../../shared/widgets/icono_circular.dart';
import '../../../../shared/widgets/tarjeta_dato.dart';
import '../../../../shared/widgets/titulo_seccion.dart';
import '../../../mapa/domain/progreso_ruta.dart';
import '../../../mapa/presentation/view_models/mapa_view_model.dart';
import '../../domain/espacio.dart';
import '../view_models/explorar_view_model.dart';

/// Pantalla principal del turista: lo que debe saber antes de ir, la ruta,
/// los atractivos y los servicios de la comunidad.
class ExplorarPage extends ConsumerWidget {
  const ExplorarPage({super.key});

  static const _margen = EdgeInsets.symmetric(horizontal: AppEspacios.l);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final espacio = ref.watch(explorarViewModelProvider);
    final progreso = ref.watch(mapaViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitulo),
        actions: [
          IconButton(
            tooltip: l10n.modoAsociacion,
            icon: const Icon(Icons.storefront_outlined),
            onPressed: () => context.go(Rutas.asociacionHoy),
          ),
          const BotonAjustes(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppEspacios.bajoBotonFlotante),
        children: [
          _Portada(espacio: espacio),
          Padding(
            padding: _margen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TituloSeccion(l10n.explorarAntesDeIr),
                _DatosPracticos(espacio: espacio),
                TituloSeccion(l10n.explorarRuta),
                _TarjetaRuta(progreso: progreso),
                TituloSeccion(l10n.explorarAtractivos),
              ],
            ),
          ),
          _Atractivos(atractivos: espacio.atractivos),
          Padding(
            padding: _margen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TituloSeccion(l10n.explorarServicios),
                for (final servicio in espacio.servicios)
                  _TarjetaServicio(servicio: servicio),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Nombre y ubicación del espacio: lo primero que ve el turista.
class _Portada extends StatelessWidget {
  const _Portada({required this.espacio});

  final Espacio espacio;

  @override
  Widget build(BuildContext context) {
    final textos = context.textos;
    final frente = context.colores.sobreEncabezado;

    return Encabezado(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.place_outlined, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  espacio.ubicacion,
                  style: textos.bodyMedium?.copyWith(color: frente),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppEspacios.s),
          Semantics(
            header: true,
            child: Text(
              espacio.nombre,
              style: textos.headlineSmall?.copyWith(color: frente),
            ),
          ),
          const SizedBox(height: AppEspacios.s),
          Text(
            context.l10n.explorarLema,
            style: textos.bodyLarge?.copyWith(color: frente),
          ),
        ],
      ),
    );
  }
}

/// Las cuatro respuestas que el turista busca antes de viajar.
class _DatosPracticos extends StatelessWidget {
  const _DatosPracticos({required this.espacio});

  final Espacio espacio;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        _Par(
          TarjetaDato(
            icono: Icons.payments_outlined,
            etiqueta: l10n.datoPago,
            valor: espacio.mediosPago.join(' · '),
          ),
          TarjetaDato(
            icono: Icons.signal_cellular_alt,
            etiqueta: l10n.datoSenal,
            valor: espacio.senal,
          ),
        ),
        const SizedBox(height: AppEspacios.s),
        _Par(
          TarjetaDato(
            icono: Icons.directions_car_outlined,
            etiqueta: l10n.datoAcceso,
            valor: espacio.acceso,
          ),
          TarjetaDato(
            icono: Icons.hiking,
            etiqueta: l10n.datoIngreso,
            valor: l10n.datoIngresoConGuia,
          ),
        ),
      ],
    );
  }
}

/// Dos tarjetas lado a lado con la misma altura.
class _Par extends StatelessWidget {
  const _Par(this.izquierda, this.derecha);

  final Widget izquierda;
  final Widget derecha;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: izquierda),
          const SizedBox(width: AppEspacios.s),
          Expanded(child: derecha),
        ],
      ),
    );
  }
}

/// Resumen de la ruta (puntos, distancia y tiempo) que lleva al mapa.
class _TarjetaRuta extends StatelessWidget {
  const _TarjetaRuta({required this.progreso});

  final ProgresoRuta progreso;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final esquema = context.esquema;
    final ruta = progreso.ruta;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(Rutas.mapa),
        child: Padding(
          padding: const EdgeInsets.all(AppEspacios.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const IconoCircular(Icons.route_outlined),
                  const SizedBox(width: AppEspacios.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ruta.nombre, style: context.textos.titleSmall),
                        const SizedBox(height: 2),
                        Text(
                          l10n.rutaResumen(
                            progreso.total,
                            formatearDistancia(
                              ruta.metrosTotales,
                              l10n.localeName,
                            ),
                            formatearDuracion(ruta.duracionTotal),
                          ),
                          style: context.textos.bodyMedium?.copyWith(
                            color: esquema.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppEspacios.m),
              LinearProgressIndicator(
                value: progreso.visitados / progreso.total,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
                semanticsLabel: l10n.mapaAvance(
                  progreso.visitados,
                  progreso.total,
                ),
              ),
              const SizedBox(height: AppEspacios.s),
              // Con letra grande, "Ver ruta" baja a la línea siguiente.
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppEspacios.s,
                children: [
                  ExcludeSemantics(
                    child: Text(
                      l10n.mapaAvance(progreso.visitados, progreso.total),
                      style: context.textos.labelMedium?.copyWith(
                        color: esquema.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          l10n.verRuta,
                          style: context.textos.labelLarge?.copyWith(
                            color: esquema.primary,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: esquema.primary),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carrusel de atractivos. La altura se adapta al texto más largo.
class _Atractivos extends StatelessWidget {
  const _Atractivos({required this.atractivos});

  final List<Atractivo> atractivos;

  static const _iconos = [
    Icons.water_drop_outlined,
    Icons.landscape_outlined,
    Icons.forest_outlined,
    Icons.terrain_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppEspacios.l),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (indice, atractivo) in atractivos.indexed) ...[
              if (indice > 0) const SizedBox(width: AppEspacios.m),
              _TarjetaAtractivo(
                atractivo: atractivo,
                icono: _iconos[indice % _iconos.length],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TarjetaAtractivo extends StatelessWidget {
  const _TarjetaAtractivo({required this.atractivo, required this.icono});

  final Atractivo atractivo;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquema;

    return SizedBox(
      width: 208,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: MergeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 76,
                width: double.infinity,
                color: esquema.primaryContainer,
                child: Icon(icono, size: 36, color: esquema.onPrimaryContainer),
              ),
              Padding(
                padding: const EdgeInsets.all(AppEspacios.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(atractivo.nombre, style: context.textos.titleSmall),
                    const SizedBox(height: AppEspacios.xs),
                    Text(
                      atractivo.descripcion,
                      style: context.textos.bodySmall?.copyWith(
                        color: esquema.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppEspacios.s),
                    EtiquetaEstado(
                      icono: Icons.qr_code_2,
                      texto: context.l10n.masUnPunto,
                      tono: TonoEtiqueta.aviso,
                    ),
                  ],
                ),
              ),
            ],
          ),
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
    final l10n = context.l10n;
    final esquema = context.esquema;
    final tarifa = servicio.tarifaReferencial;

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
                  IconoCircular(switch (servicio.tipo) {
                    TipoServicio.guiado => Icons.hiking,
                    TipoServicio.alimentacion => Icons.restaurant_outlined,
                    TipoServicio.hospedaje => Icons.hotel_outlined,
                    TipoServicio.transporte => Icons.directions_bus_outlined,
                  }),
                  const SizedBox(width: AppEspacios.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(servicio.nombre, style: context.textos.titleSmall),
                        Text(
                          servicio.tipo.texto(l10n),
                          style: context.textos.labelMedium?.copyWith(
                            color: esquema.primary,
                          ),
                        ),
                        if (tarifa != null)
                          Text(
                            tarifa,
                            style: context.textos.bodyMedium?.copyWith(
                              color: esquema.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppEspacios.m),
              FilledButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.whatsappNumero(servicio.whatsapp)),
                  ),
                ),
                icon: const Icon(Icons.chat_outlined),
                label: Text(l10n.contactarWhatsapp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
