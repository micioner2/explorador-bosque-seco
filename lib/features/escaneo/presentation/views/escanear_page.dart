import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/router/rutas.dart';
import '../../../../core/theme/app_espacios.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/colores_app.dart';
import '../../domain/resultado_escaneo.dart';
import '../view_models/escaneo_view_model.dart';
import 'visor_camara.dart';

/// Un solo lector para todo: el QR del grupo vincula el celular del
/// turista con su visita, y el QR de cada punto de la ruta da su sello.
/// Funciona en modo avión.
class EscanearPage extends ConsumerStatefulWidget {
  const EscanearPage({super.key});

  @override
  ConsumerState<EscanearPage> createState() => _EscanearPageState();
}

class _EscanearPageState extends ConsumerState<EscanearPage> {
  void _procesar(String texto) =>
      ref.read(escaneoViewModelProvider.notifier).procesar(texto);

  Future<void> _escribirCodigo() async {
    final codigo = await showDialog<String>(
      context: context,
      builder: (context) => const _DialogoCodigo(),
    );
    if (codigo != null && codigo.trim().isNotEmpty) _procesar(codigo);
  }

  @override
  Widget build(BuildContext context) {
    final resultado = ref.watch(escaneoViewModelProvider);
    final vinculado = ref.watch(vinculoViewModelProvider) != null;
    final visor = ref.watch(visorCamaraProvider);

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppEspacios.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _EstadoGrupo(vinculado: vinculado),
                    const SizedBox(height: AppEspacios.l),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppEspacios.radio,
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                visor(context, _procesar),
                                const IgnorePointer(child: _Marco()),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppEspacios.l),
                    Text(
                      l10n.escanearInstruccion,
                      textAlign: TextAlign.center,
                      style: context.textos.titleMedium,
                    ),
                    const SizedBox(height: AppEspacios.xs),
                    Text(
                      l10n.escanearSinSenal,
                      textAlign: TextAlign.center,
                      style: context.textos.bodyMedium?.copyWith(
                        color: context.esquema.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppEspacios.l),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: resultado == null
                          ? const SizedBox.shrink()
                          : _PanelResultado(
                              key: ValueKey(resultado),
                              resultado: resultado,
                            ),
                    ),
                    const SizedBox(height: AppEspacios.s),
                    TextButton.icon(
                      onPressed: _escribirCodigo,
                      icon: const Icon(Icons.keyboard_outlined),
                      label: Text(l10n.escanearEscribirCodigo),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Si el celular ya está vinculado a un grupo, o qué hacer primero.
class _EstadoGrupo extends StatelessWidget {
  const _EstadoGrupo({required this.vinculado});

  final bool vinculado;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final esquema = context.esquema;
    final fondo = vinculado
        ? esquema.primaryContainer
        : esquema.surfaceContainerHighest;
    final frente = vinculado ? esquema.onPrimaryContainer : esquema.onSurface;

    return MergeSemantics(
      child: Container(
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(AppEspacios.radioChico),
        ),
        padding: const EdgeInsets.all(AppEspacios.m),
        child: Row(
          children: [
            Icon(vinculado ? Icons.groups : Icons.qr_code_2, color: frente),
            const SizedBox(width: AppEspacios.m),
            Expanded(
              child: Text(
                vinculado ? l10n.escanearConGrupo : l10n.escanearSinGrupo,
                style: context.textos.bodyMedium?.copyWith(color: frente),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Esquinas que marcan dónde encuadrar el QR, sobre la cámara.
class _Marco extends StatelessWidget {
  const _Marco();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.all(AppEspacios.xl),
        child: CustomPaint(painter: _PintorMarco(context.colores.sobreAviso)),
      ),
    );
  }
}

class _PintorMarco extends CustomPainter {
  const _PintorMarco(this.color);

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
  bool shouldRepaint(_PintorMarco anterior) => anterior.color != color;
}

/// Respuesta inmediata al escanear: qué pasó y qué hacer después.
class _PanelResultado extends StatelessWidget {
  const _PanelResultado({required this.resultado, super.key});

  final ResultadoEscaneo resultado;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final esquema = context.esquema;
    final textos = context.textos;
    final exito = switch (resultado) {
      GrupoVinculado() || SelloGanado() => true,
      CuponLeido(:final valido) => valido,
      _ => false,
    };
    final frente = exito ? esquema.onPrimaryContainer : esquema.onSurface;

    final (IconData icono, String titulo, String detalle) = switch (resultado) {
      GrupoVinculado(:final yaEstaba) => (
        Icons.groups,
        yaEstaba ? l10n.escanearGrupoYaEstaba : l10n.escanearGrupoListo,
        l10n.escanearGrupoDetalle,
      ),
      SelloGanado(:final punto) => (
        Icons.verified,
        l10n.escanearGanadoEn(punto.nombre),
        l10n.escanearGanadoDetalle,
      ),
      SelloRepetido(:final punto) => (
        Icons.info_outline,
        l10n.escanearRepetido(punto.nombre),
        l10n.escanearRepetidoDetalle,
      ),
      FaltaGrupo(:final punto) => (
        Icons.group_add_outlined,
        l10n.escanearFaltaGrupo,
        l10n.escanearFaltaGrupoDetalle(punto.nombre),
      ),
      CuponLeido(:final valido, :final porcentaje, :final nombreProducto) =>
        valido
            ? (
                Icons.local_offer,
                l10n.escanearCuponValido(porcentaje, nombreProducto),
                l10n.escanearCuponValidoDetalle,
              )
            : (
                Icons.block,
                l10n.escanearCuponUsado,
                l10n.escanearCuponUsadoDetalle,
              ),
      CuponDelTurista() => (
        Icons.local_offer_outlined,
        l10n.escanearCuponTurista,
        l10n.escanearCuponTuristaDetalle,
      ),
      PuntoAjeno() => (
        Icons.help_outline,
        l10n.escanearPuntoAjeno,
        l10n.escanearAjenoDetalle,
      ),
      QrAjeno() => (
        Icons.help_outline,
        l10n.escanearQrAjeno,
        l10n.escanearAjenoDetalle,
      ),
    };

    final accion = switch (resultado) {
      GrupoVinculado() => (l10n.verRuta, Rutas.mapa),
      SelloGanado() || SelloRepetido() => (l10n.verPasaporte, Rutas.pasaporte),
      _ => null,
    };

    return Semantics(
      liveRegion: true,
      child: Container(
        decoration: BoxDecoration(
          color: exito
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
                Icon(icono, size: 28, color: frente),
                const SizedBox(width: AppEspacios.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: textos.titleSmall?.copyWith(color: frente),
                      ),
                      Text(
                        detalle,
                        style: textos.bodyMedium?.copyWith(color: frente),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (accion != null) ...[
              const SizedBox(height: AppEspacios.m),
              FilledButton(
                onPressed: () => context.go(accion.$2),
                child: Text(accion.$1),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Plan B si la cámara no lee el cartel: escribir el código del punto.
class _DialogoCodigo extends StatefulWidget {
  const _DialogoCodigo();

  @override
  State<_DialogoCodigo> createState() => _DialogoCodigoState();
}

class _DialogoCodigoState extends State<_DialogoCodigo> {
  final _codigo = TextEditingController();

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.escanearCodigoTitulo),
      content: TextField(
        controller: _codigo,
        autofocus: true,
        autocorrect: false,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(helperText: l10n.escanearCodigoAyuda),
        onSubmitted: (texto) => Navigator.of(context).pop(texto),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelar),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_codigo.text),
          child: Text(l10n.escanearCodigoAccion),
        ),
      ],
    );
  }
}
