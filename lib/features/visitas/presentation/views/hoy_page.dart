import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_espacios.dart';
import '../../../../core/theme/colores_app.dart';
import '../../../../shared/widgets/acciones_barra.dart';
import '../../../../shared/widgets/dialogo_confirmar.dart';
import '../../../../shared/widgets/estado_vacio.dart';
import '../../../../shared/widgets/tarjeta_cifra.dart';
import '../../../../shared/widgets/titulo_seccion.dart';
import '../../domain/visita.dart';
import '../view_models/visitas_view_model.dart';
import 'qr_grupo_dialog.dart';

/// Panel del puesto de control: quién está dentro del bosque y alertas.
class HoyPage extends ConsumerWidget {
  const HoyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final resumen = ref.watch(resumenDelDiaProvider);
    final atrasadas = resumen.atrasadas;
    // Primero los grupos que ya debieron salir: son los que urgen.
    final enOrden = [
      ...atrasadas,
      for (final visita in resumen.dentro)
        if (!atrasadas.contains(visita)) visita,
    ];

    Future<void> marcarSalida(Visita visita) async {
      final mensajero = ScaffoldMessenger.of(context);
      final aceptado = await confirmar(
        context,
        titulo: l10n.salidaConfirmarTitulo,
        detalle: l10n.salidaConfirmarDetalle(
          visita.nombreResponsable,
          visita.tamanoGrupo,
        ),
        accion: l10n.marcarSalida,
      );
      if (!aceptado || !context.mounted) return;
      ref.read(visitasViewModelProvider.notifier).marcarSalida(visita.id);
      mensajero.showSnackBar(
        SnackBar(content: Text(l10n.salidaMarcada(visita.nombreResponsable))),
      );
    }

    return Scaffold(
      appBar: BarraAsociacion(titulo: l10n.hoyTitulo),
      body: ListView(
        padding: const EdgeInsets.all(AppEspacios.l),
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: TarjetaCifra(
                    icono: Icons.forest_outlined,
                    etiqueta: l10n.hoyDentro,
                    valor: '${resumen.personasDentro}',
                    destacada: true,
                  ),
                ),
                const SizedBox(width: AppEspacios.s),
                Expanded(
                  child: TarjetaCifra(
                    icono: Icons.logout,
                    etiqueta: l10n.hoySalieron,
                    valor: '${resumen.personasQueSalieron}',
                  ),
                ),
                const SizedBox(width: AppEspacios.s),
                Expanded(
                  child: TarjetaCifra(
                    icono: Icons.groups_outlined,
                    etiqueta: l10n.hoyTotal,
                    valor: '${resumen.personasTotal}',
                  ),
                ),
              ],
            ),
          ),
          if (atrasadas.isNotEmpty) ...[
            const SizedBox(height: AppEspacios.m),
            _AvisoAtrasadas(cantidad: atrasadas.length),
          ],
          TituloSeccion(l10n.hoyDentroDelBosque),
          if (enOrden.isEmpty)
            EstadoVacio(
              icono: Icons.forest_outlined,
              titulo: l10n.hoySinGrupos,
              detalle: l10n.hoySinGruposDetalle,
            ),
          for (final visita in enOrden)
            _TarjetaGrupo(
              visita: visita,
              atrasada: atrasadas.contains(visita),
              onMarcarSalida: () => marcarSalida(visita),
            ),
        ],
      ),
    );
  }
}

/// Alerta "sigue dentro": hay grupos que pasaron su hora de salida.
class _AvisoAtrasadas extends StatelessWidget {
  const _AvisoAtrasadas({required this.cantidad});

  final int cantidad;

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquema;

    return Semantics(
      liveRegion: true,
      child: Container(
        decoration: BoxDecoration(
          color: esquema.errorContainer,
          borderRadius: BorderRadius.circular(AppEspacios.radioChico),
        ),
        padding: const EdgeInsets.all(AppEspacios.m),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: esquema.onErrorContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.l10n.hoyAlerta(cantidad),
                style: context.textos.titleSmall?.copyWith(
                  color: esquema.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Un grupo que sigue en el bosque: se puede volver a mostrar su QR o
/// marcar su salida.
class _TarjetaGrupo extends StatelessWidget {
  const _TarjetaGrupo({
    required this.visita,
    required this.atrasada,
    required this.onMarcarSalida,
  });

  final Visita visita;
  final bool atrasada;
  final VoidCallback onMarcarSalida;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final esquema = context.esquema;
    final textos = context.textos;
    final hora = TimeOfDay.fromDateTime(visita.salidaPrevista).format(context);
    final guia = visita.guia;
    final secundario = atrasada
        ? esquema.onErrorContainer
        : esquema.onSurfaceVariant;
    const icono = Icon(Icons.logout, size: 20);
    final etiqueta = Text(l10n.marcarSalida);
    // Dos botones en una fila: menos relleno para que quepan en celulares
    // angostos, y la misma altura para que se vean parejos.
    const compacto = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(64, 52)),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: AppEspacios.m,
          vertical: AppEspacios.m,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppEspacios.m),
      child: Card(
        color: atrasada ? esquema.errorContainer : null,
        shape: atrasada
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppEspacios.radio),
                side: BorderSide(color: esquema.error, width: 1.5),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(AppEspacios.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MergeSemantics(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Insignia(personas: visita.tamanoGrupo, atrasada: atrasada),
                    const SizedBox(width: AppEspacios.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (atrasada)
                            Text(
                              l10n.hoySigueDentro.toUpperCase(),
                              semanticsLabel: l10n.hoySigueDentro,
                              style: textos.labelSmall?.copyWith(
                                color: esquema.onErrorContainer,
                              ),
                            ),
                          Text(
                            visita.nombreResponsable,
                            style: textos.titleSmall?.copyWith(
                              color: atrasada
                                  ? esquema.onErrorContainer
                                  : esquema.onSurface,
                            ),
                          ),
                          Text(
                            l10n.hoyGrupo(
                              visita.tamanoGrupo,
                              textoActividades(visita, l10n),
                            ),
                            style: textos.bodyMedium?.copyWith(
                              color: secundario,
                            ),
                          ),
                          Text(
                            atrasada
                                ? l10n.hoyDebiaSalir(hora)
                                : l10n.hoySalidaPrevista(hora),
                            style: textos.bodyMedium?.copyWith(
                              color: secundario,
                              fontWeight: atrasada ? FontWeight.w700 : null,
                            ),
                          ),
                          if (guia != null)
                            Text(
                              guia,
                              style: textos.bodyMedium?.copyWith(
                                color: secundario,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppEspacios.m),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      style: compacto,
                      onPressed: () => mostrarQrGrupo(context, visita),
                      icon: const Icon(Icons.qr_code_2, size: 20),
                      label: Text(l10n.verQr),
                    ),
                  ),
                  const SizedBox(width: AppEspacios.s),
                  Expanded(
                    flex: 3,
                    child: atrasada
                        ? FilledButton.icon(
                            style: compacto,
                            onPressed: onMarcarSalida,
                            icon: icono,
                            label: etiqueta,
                          )
                        : OutlinedButton.icon(
                            style: compacto,
                            onPressed: onMarcarSalida,
                            icon: icono,
                            label: etiqueta,
                          ),
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

/// Cantidad de personas del grupo, visible de un vistazo.
class _Insignia extends StatelessWidget {
  const _Insignia({required this.personas, required this.atrasada});

  final int personas;
  final bool atrasada;

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquema;

    return ExcludeSemantics(
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: atrasada ? esquema.error : esquema.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(AppEspacios.xs),
            child: Text(
              '$personas',
              style: context.textos.titleMedium?.copyWith(
                color: atrasada ? esquema.onError : esquema.onPrimaryContainer,
              ),
              textScaler: TextScaler.noScaling,
            ),
          ),
        ),
      ),
    );
  }
}
