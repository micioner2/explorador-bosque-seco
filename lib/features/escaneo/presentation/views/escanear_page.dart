import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/router/rutas.dart';
import '../../../../core/theme/app_espacios.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/colores_app.dart';
import '../../../puntos/domain/pasaporte.dart';
import '../../../puntos/presentation/view_models/pasaporte_view_model.dart';

/// Lector de QR de los puntos turísticos.
///
/// Siguiente paso: integrar `mobile_scanner`. Mientras tanto, el botón de
/// demostración registra el punto "mirador" con la misma lógica real.
class EscanearPage extends ConsumerStatefulWidget {
  const EscanearPage({super.key});

  @override
  ConsumerState<EscanearPage> createState() => _EscanearPageState();
}

class _EscanearPageState extends ConsumerState<EscanearPage> {
  /// Resultado del último escaneo; se muestra en la misma pantalla.
  ResultadoRegistro? _resultado;

  void _registrarDemo() {
    final resultado = ref
        .read(pasaporteViewModelProvider.notifier)
        .registrarEscaneo(visitaId: 'v-demo', puntoId: 'mirador');
    setState(() => _resultado = resultado);
  }

  @override
  Widget build(BuildContext context) {
    final resultado = _resultado;

    // La cámara siempre se usa sobre fondo oscuro, también en modo claro.
    return Theme(
      data: AppTheme.oscuro,
      child: Builder(
        builder: (context) {
          final l10n = context.l10n;
          final fondo = Theme.of(context).scaffoldBackgroundColor;

          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.escanearTitulo),
              backgroundColor: fondo,
            ),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppEspacios.xl),
                  child: Column(
                    children: [
                      const _Visor(),
                      const SizedBox(height: AppEspacios.xl),
                      Text(
                        l10n.escanearInstruccion,
                        textAlign: TextAlign.center,
                        style: context.textos.titleMedium,
                      ),
                      const SizedBox(height: AppEspacios.s),
                      Text(
                        l10n.escanearSinSenal,
                        textAlign: TextAlign.center,
                        style: context.textos.bodyMedium?.copyWith(
                          color: context.esquema.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppEspacios.xl),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: resultado == null
                            ? const SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppEspacios.xl,
                                ),
                                child: _PanelResultado(resultado: resultado),
                              ),
                      ),
                      OutlinedButton(
                        onPressed: _registrarDemo,
                        child: Text(l10n.escanearSimular),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Marco donde se encuadra el QR.
class _Visor extends StatelessWidget {
  const _Visor();

  @override
  Widget build(BuildContext context) {
    final color = context.colores.sobreAviso;

    return ExcludeSemantics(
      child: SizedBox(
        width: 240,
        height: 240,
        child: CustomPaint(
          painter: _PintorVisor(color),
          child: Icon(
            Icons.qr_code_2,
            size: 96,
            color: color.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

class _PintorVisor extends CustomPainter {
  const _PintorVisor(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const largo = 44.0;
    const radio = Radius.circular(24);
    final pincel = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = color;
    final marco = RRect.fromRectAndRadius(Offset.zero & size, radio);

    // Solo se dibujan las cuatro esquinas del marco.
    canvas.save();
    canvas.clipPath(
      Path()
        ..addRect(const Rect.fromLTWH(0, 0, largo, largo))
        ..addRect(Rect.fromLTWH(size.width - largo, 0, largo, largo))
        ..addRect(Rect.fromLTWH(0, size.height - largo, largo, largo))
        ..addRect(
          Rect.fromLTWH(size.width - largo, size.height - largo, largo, largo),
        ),
    );
    canvas.drawRRect(marco.deflate(3), pincel);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PintorVisor anterior) => anterior.color != color;
}

/// Respuesta inmediata al escanear: se ganó el sello o ya estaba.
class _PanelResultado extends StatelessWidget {
  const _PanelResultado({required this.resultado});

  final ResultadoRegistro resultado;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final esquema = context.esquema;
    final textos = context.textos;
    final ganado = resultado is PuntoGanado;
    final frente = ganado ? esquema.onPrimaryContainer : esquema.onSurface;

    return Semantics(
      liveRegion: true,
      child: Container(
        decoration: BoxDecoration(
          color: ganado
              ? esquema.primaryContainer
              : esquema.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppEspacios.radio),
        ),
        padding: const EdgeInsets.all(AppEspacios.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  ganado ? Icons.verified : Icons.info_outline,
                  size: 28,
                  color: frente,
                ),
                const SizedBox(width: AppEspacios.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(switch (resultado) {
                        PuntoGanado() => l10n.escanearGanado,
                        PuntoYaRegistrado() => l10n.escanearYaRegistrado,
                      }, style: textos.titleSmall?.copyWith(color: frente)),
                      if (ganado)
                        Text(
                          l10n.escanearGanadoDetalle,
                          style: textos.bodyMedium?.copyWith(color: frente),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppEspacios.m),
            FilledButton(
              onPressed: () => context.go(Rutas.pasaporte),
              child: Text(l10n.verPasaporte),
            ),
          ],
        ),
      ),
    );
  }
}
