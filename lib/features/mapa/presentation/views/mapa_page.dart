import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/formato.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/router/rutas.dart';
import '../../../../core/theme/app_espacios.dart';
import '../../../../core/theme/colores_app.dart';
import '../../../../shared/widgets/acciones_barra.dart';
import '../../../../shared/widgets/estado_vacio.dart';
import '../../../../shared/widgets/etiqueta_estado.dart';
import '../../../../shared/widgets/titulo_seccion.dart';
import '../../../escaneo/presentation/view_models/escaneo_view_model.dart';
import '../../../sincronizacion/presentation/view_models/sincronizacion_view_model.dart';
import '../../../sincronizacion/presentation/views/aviso_conexion.dart';
import '../../domain/progreso_ruta.dart';
import '../view_models/mapa_view_model.dart';
import 'mapa_ruta.dart';

/// Ruta del turista: siguiente punto, mapa con GPS, distancias y avance.
/// Todo funciona sin señal. Si la ruta aún no tiene coordenadas, se
/// muestra el esquema dibujado ([_EsquemaRuta]).
class MapaPage extends ConsumerWidget {
  const MapaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final vinculado = ref.watch(vinculoViewModelProvider) != null;

    // Sin grupo vinculado no se muestra la ruta ni los puntos: primero hay
    // que escanear el QR del grupo, igual que en el pasaporte.
    if (!vinculado) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.navMapa),
          actions: const [BotonAjustes()],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppEspacios.l,
            AppEspacios.xl,
            AppEspacios.l,
            AppEspacios.bajoBotonFlotante,
          ),
          children: [
            EstadoVacio(
              icono: Icons.qr_code_2,
              titulo: l10n.mapaSinGrupo,
              detalle: l10n.mapaSinGrupoDetalle,
            ),
            FilledButton.icon(
              onPressed: () => context.push<void>(Rutas.escanear),
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(l10n.pasaporteEscanearGrupo),
            ),
          ],
        ),
      );
    }

    final progreso = ref.watch(mapaViewModelProvider);
    final ruta = progreso.ruta;

    return Scaffold(
      appBar: AppBar(title: Text(ruta.nombre), actions: const [BotonAjustes()]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppEspacios.l,
          AppEspacios.l,
          AppEspacios.l,
          AppEspacios.bajoBotonFlotante,
        ),
        children: [
          AvisoConexion(estado: ref.watch(estadoTuristaProvider)),
          const SizedBox(height: AppEspacios.m),
          _TarjetaSiguiente(progreso: progreso),
          const SizedBox(height: AppEspacios.m),
          if (ruta.georreferenciada)
            MapaRuta(progreso: progreso)
          else
            _EsquemaRuta(progreso: progreso),
          TituloSeccion(l10n.mapaRecorrido),
          Text(
            l10n.mapaTotal(
              formatearDistancia(ruta.metrosTotales, l10n.localeName),
              formatearDuracion(ruta.duracionTotal),
            ),
            style: context.textos.bodyMedium?.copyWith(
              color: context.esquema.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppEspacios.l),
          for (final punto in progreso.puntos)
            _FilaPunto(
              punto: punto,
              esSiguiente: punto == progreso.siguiente,
              esUltimo: punto.orden == progreso.total,
            ),
        ],
      ),
    );
  }
}

/// Lo más importante de la pantalla: a dónde ir ahora y cuánto falta.
class _TarjetaSiguiente extends StatelessWidget {
  const _TarjetaSiguiente({required this.progreso});

  final ProgresoRuta progreso;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final esquema = context.esquema;
    final textos = context.textos;
    final frente = esquema.onPrimaryContainer;
    final siguiente = progreso.siguiente;
    final avance = l10n.mapaAvance(progreso.visitados, progreso.total);

    return Container(
      decoration: BoxDecoration(
        color: esquema.primaryContainer,
        borderRadius: BorderRadius.circular(AppEspacios.radio),
      ),
      padding: const EdgeInsets.all(AppEspacios.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (siguiente == null) ...[
            Row(
              children: [
                Icon(Icons.emoji_events_outlined, size: 32, color: frente),
                const SizedBox(width: AppEspacios.m),
                Expanded(
                  child: Text(
                    l10n.mapaRutaCompletada,
                    style: textos.titleLarge?.copyWith(color: frente),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppEspacios.s),
            Text(
              l10n.mapaRutaCompletadaDetalle,
              style: textos.bodyMedium?.copyWith(color: frente),
            ),
          ] else ...[
            Text(
              l10n.mapaSiguientePunto.toUpperCase(),
              semanticsLabel: l10n.mapaSiguientePunto,
              style: textos.labelSmall?.copyWith(color: frente),
            ),
            const SizedBox(height: AppEspacios.xs),
            Text(
              '${siguiente.orden} · ${siguiente.punto.nombre}',
              style: textos.titleLarge?.copyWith(color: frente),
            ),
            const SizedBox(height: AppEspacios.m),
            if (siguiente.punto.metrosDesdeAnterior == 0)
              Text(
                l10n.mapaInicio,
                style: textos.bodyMedium?.copyWith(color: frente),
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _Medida(
                      icono: Icons.straighten,
                      valor: formatearDistancia(
                        siguiente.punto.metrosDesdeAnterior,
                        l10n.localeName,
                      ),
                      detalle: l10n.mapaDesdeAnterior,
                    ),
                  ),
                  const SizedBox(width: AppEspacios.m),
                  Expanded(
                    child: _Medida(
                      icono: Icons.schedule,
                      valor: formatearDuracion(
                        siguiente.punto.duracionDesdeAnterior,
                      ),
                      detalle: l10n.mapaAPie,
                    ),
                  ),
                ],
              ),
          ],
          const SizedBox(height: AppEspacios.l),
          LinearProgressIndicator(
            value: progreso.visitados / progreso.total,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
            backgroundColor: esquema.surface,
            semanticsLabel: avance,
          ),
          const SizedBox(height: AppEspacios.s),
          ExcludeSemantics(
            child: Text(
              avance,
              style: textos.labelMedium?.copyWith(color: frente),
            ),
          ),
        ],
      ),
    );
  }
}

/// Un número grande con su explicación debajo ("850 m · desde el punto
/// anterior").
class _Medida extends StatelessWidget {
  const _Medida({
    required this.icono,
    required this.valor,
    required this.detalle,
  });

  final IconData icono;
  final String valor;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    final frente = context.esquema.onPrimaryContainer;

    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 20, color: frente),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  valor,
                  style: context.textos.headlineSmall?.copyWith(color: frente),
                ),
              ),
            ],
          ),
          Text(
            detalle,
            style: context.textos.bodySmall?.copyWith(color: frente),
          ),
        ],
      ),
    );
  }
}

/// Dibujo simple del recorrido con sus puntos numerados, para rutas que aún
/// no tienen coordenadas.
class _EsquemaRuta extends StatelessWidget {
  const _EsquemaRuta({required this.progreso});

  final ProgresoRuta progreso;

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquema;

    return Container(
      decoration: BoxDecoration(
        color: context.colores.mapa,
        borderRadius: BorderRadius.circular(AppEspacios.radio),
        border: Border.all(color: esquema.outlineVariant),
      ),
      padding: const EdgeInsets.all(AppEspacios.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // El recorrido de abajo dice lo mismo con texto.
          ExcludeSemantics(
            child: SizedBox(
              height: 132,
              width: double.infinity,
              child: CustomPaint(
                painter: _PintorRuta(
                  estados: [
                    for (final punto in progreso.puntos)
                      punto == progreso.siguiente
                          ? _Marca.siguiente
                          : punto.visitado
                          ? _Marca.visitado
                          : _Marca.porVisitar,
                  ],
                  recorrido: esquema.primary,
                  porRecorrer: esquema.outline,
                  sobreRecorrido: esquema.onPrimary,
                  siguiente: esquema.secondary,
                  sobreSiguiente: esquema.onSecondary,
                  fondo: esquema.surface,
                  texto: esquema.onSurfaceVariant,
                  estiloNumero: context.textos.labelLarge!,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppEspacios.s),
          Text(
            context.l10n.mapaEsquema,
            style: context.textos.bodySmall?.copyWith(
              color: esquema.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

enum _Marca { visitado, siguiente, porVisitar }

class _PintorRuta extends CustomPainter {
  const _PintorRuta({
    required this.estados,
    required this.recorrido,
    required this.porRecorrer,
    required this.sobreRecorrido,
    required this.siguiente,
    required this.sobreSiguiente,
    required this.fondo,
    required this.texto,
    required this.estiloNumero,
  });

  final List<_Marca> estados;
  final Color recorrido;
  final Color porRecorrer;
  final Color sobreRecorrido;
  final Color siguiente;
  final Color sobreSiguiente;
  final Color fondo;
  final Color texto;

  /// Tipografía del tema para los números de cada punto.
  final TextStyle estiloNumero;

  static const _radio = 15.0;

  @override
  void paint(Canvas canvas, Size size) {
    final centros = _centros(size);

    // Tramos: línea continua si ya se caminó, punteada si falta.
    for (var i = 0; i < centros.length - 1; i++) {
      final desde = centros[i];
      final hasta = centros[i + 1];
      final medio = (desde.dx + hasta.dx) / 2;
      final tramo = Path()
        ..moveTo(desde.dx, desde.dy)
        ..cubicTo(medio, desde.dy, medio, hasta.dy, hasta.dx, hasta.dy);
      final caminado = estados[i + 1] == _Marca.visitado;
      final pincel = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = caminado ? recorrido : porRecorrer;
      canvas.drawPath(caminado ? tramo : _punteado(tramo), pincel);
    }

    for (final (i, centro) in centros.indexed) {
      final estado = estados[i];
      final relleno = switch (estado) {
        _Marca.visitado => recorrido,
        _Marca.siguiente => siguiente,
        _Marca.porVisitar => fondo,
      };
      final numero = switch (estado) {
        _Marca.visitado => sobreRecorrido,
        _Marca.siguiente => sobreSiguiente,
        _Marca.porVisitar => texto,
      };
      if (estado == _Marca.siguiente) {
        canvas.drawCircle(
          centro,
          _radio + 6,
          Paint()..color = siguiente.withValues(alpha: 0.25),
        );
      }
      canvas.drawCircle(centro, _radio, Paint()..color = relleno);
      if (estado == _Marca.porVisitar) {
        canvas.drawCircle(
          centro,
          _radio,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = porRecorrer,
        );
      }
      final etiqueta = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: estiloNumero.copyWith(color: numero, fontSize: 14),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      etiqueta.paint(
        canvas,
        centro - Offset(etiqueta.width / 2, etiqueta.height / 2),
      );
    }
  }

  /// Reparte los puntos de izquierda a derecha, subiendo y bajando como un
  /// sendero.
  List<Offset> _centros(Size size) {
    const margen = _radio + 8;
    final cantidad = estados.length;
    if (cantidad == 1) return [size.center(Offset.zero)];
    final paso = (size.width - 2 * margen) / (cantidad - 1);
    return [
      for (var i = 0; i < cantidad; i++)
        Offset(margen + paso * i, i.isEven ? size.height - margen : margen),
    ];
  }

  Path _punteado(Path origen) {
    const trazo = 8.0;
    const hueco = 8.0;
    final resultado = Path();
    for (final medida in origen.computeMetrics()) {
      var distancia = 0.0;
      while (distancia < medida.length) {
        resultado.addPath(
          medida.extractPath(distancia, distancia + trazo),
          Offset.zero,
        );
        distancia += trazo + hueco;
      }
    }
    return resultado;
  }

  @override
  bool shouldRepaint(_PintorRuta anterior) =>
      !_mismasMarcas(anterior.estados) ||
      anterior.recorrido != recorrido ||
      anterior.porRecorrer != porRecorrer ||
      anterior.siguiente != siguiente ||
      anterior.fondo != fondo ||
      anterior.texto != texto;

  bool _mismasMarcas(List<_Marca> otras) {
    if (otras.length != estados.length) return false;
    for (var i = 0; i < estados.length; i++) {
      if (otras[i] != estados[i]) return false;
    }
    return true;
  }
}

/// Un punto del recorrido con su estado y el tramo que lleva hasta él.
class _FilaPunto extends StatelessWidget {
  const _FilaPunto({
    required this.punto,
    required this.esSiguiente,
    required this.esUltimo,
  });

  final PuntoEnRuta punto;
  final bool esSiguiente;
  final bool esUltimo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final esquema = context.esquema;
    final textos = context.textos;
    final tramo = punto.punto.metrosDesdeAnterior == 0
        ? l10n.mapaInicio
        : '${formatearDistancia(punto.punto.metrosDesdeAnterior, l10n.localeName)}'
              ' · ${formatearDuracion(punto.punto.duracionDesdeAnterior)}';

    return MergeSemantics(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 36,
              child: Column(
                children: [
                  _Marcador(punto: punto, esSiguiente: esSiguiente),
                  if (!esUltimo)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: punto.visitado
                            ? esquema.primary
                            : esquema.outlineVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppEspacios.m),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 6,
                  bottom: esUltimo ? 0 : AppEspacios.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppEspacios.s,
                      runSpacing: AppEspacios.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(punto.punto.nombre, style: textos.titleSmall),
                        if (esSiguiente)
                          EtiquetaEstado(
                            icono: Icons.near_me,
                            texto: l10n.estadoSiguiente,
                            tono: TonoEtiqueta.acento,
                          ),
                        if (punto.estado == EstadoPunto.confirmado)
                          EtiquetaEstado(
                            icono: Icons.check,
                            texto: l10n.estadoVisitado,
                            tono: TonoEtiqueta.exito,
                          ),
                        if (punto.estado == EstadoPunto.pendiente)
                          EtiquetaEstado(
                            icono: Icons.sync,
                            texto: l10n.estadoPendiente,
                            tono: TonoEtiqueta.aviso,
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.directions_walk,
                          size: 16,
                          color: esquema.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            tramo,
                            style: textos.bodyMedium?.copyWith(
                              color: esquema.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Círculo numerado del recorrido. Además del color, cambia el icono:
/// visto (confirmado), sincronizando (pendiente) o el número (por visitar).
class _Marcador extends StatelessWidget {
  const _Marcador({required this.punto, required this.esSiguiente});

  final PuntoEnRuta punto;
  final bool esSiguiente;

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquema;
    final colores = context.colores;
    final (fondo, frente, borde) = switch (punto.estado) {
      EstadoPunto.confirmado => (
        esquema.primary,
        esquema.onPrimary,
        esquema.primary,
      ),
      EstadoPunto.pendiente => (
        colores.aviso,
        colores.sobreAviso,
        colores.sobreAviso,
      ),
      EstadoPunto.porVisitar => (
        esquema.surface,
        esSiguiente ? esquema.primary : esquema.onSurfaceVariant,
        esSiguiente ? esquema.primary : esquema.outline,
      ),
    };

    return ExcludeSemantics(
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fondo,
          shape: BoxShape.circle,
          border: Border.all(color: borde, width: 2),
        ),
        child: switch (punto.estado) {
          EstadoPunto.confirmado => Icon(Icons.check, size: 20, color: frente),
          EstadoPunto.pendiente => Icon(Icons.sync, size: 20, color: frente),
          EstadoPunto.porVisitar => Text(
            '${punto.orden}',
            style: context.textos.labelLarge?.copyWith(color: frente),
            textScaler: TextScaler.noScaling,
          ),
        },
      ),
    );
  }
}
