import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/formato.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/router/rutas.dart';
import '../../../../core/theme/app_espacios.dart';
import '../../../../core/theme/colores_app.dart';
import '../../../../shared/widgets/dialogo_confirmar.dart';
import '../../../../shared/widgets/etiqueta_estado.dart';
import '../../../visitas/presentation/view_models/registro_grupo_view_model.dart';
import '../../domain/reserva.dart';
import '../view_models/reservas_view_model.dart';
import 'textos_reserva.dart';

/// Una reserva pendiente con sus acciones: el grupo llegó (pasa al registro
/// de siempre; solo las de hoy o atrasadas), reprogramar o cancelar.
class TarjetaReserva extends ConsumerWidget {
  const TarjetaReserva({super.key, required this.reserva, required this.ahora});

  final Reserva reserva;

  /// Para marcar las reservas retrasadas y las que no llegaron.
  final DateTime ahora;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final esquema = context.esquema;
    final textos = context.textos;
    final retrasada = reserva.retrasada(ahora);
    final noLlego = reserva.noLlego(ahora);
    // "Llegaron" solo para las de hoy o atrasadas: en las de otro día
    // invitaría a tocarlo por error. Si llegan antes, se reprograma a hoy.
    final esperadaHoy = !DateUtils.dateOnly(
      reserva.fechaHora,
    ).isAfter(DateUtils.dateOnly(ahora));
    final telefono = reserva.telefono;
    // Dos botones en una fila: menos relleno para que quepan en celulares
    // angostos (igual que en "Dentro del bosque").
    const compacto = ButtonStyle(
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: AppEspacios.m,
          vertical: AppEspacios.m,
        ),
      ),
    );

    void llegaron() {
      ref
          .read(registroGrupoViewModelProvider.notifier)
          .atenderReserva(reserva.id);
      context.go(Rutas.asociacionRegistrar);
    }

    Future<void> cancelar() async {
      final mensajero = ScaffoldMessenger.of(context);
      final aceptado = await confirmar(
        context,
        titulo: l10n.reservaCancelarTitulo,
        detalle: l10n.reservaCancelarDetalle(
          reserva.nombreContacto,
          textoCuando(context, reserva.fechaHora, ahora),
        ),
        accion: l10n.reservaCancelarSi,
        noHacer: l10n.volver,
      );
      if (!aceptado || !context.mounted) return;
      ref.read(reservasViewModelProvider.notifier).cancelar(reserva.id);
      mensajero
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.reservaCancelada(reserva.nombreContacto)),
          ),
        );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppEspacios.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MergeSemantics(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Hora(
                    hora: textoHora(context, reserva.fechaHora),
                    fecha: noLlego
                        ? formatearFechaCorta(
                            reserva.fechaHora,
                            l10n.localeName,
                          )
                        : null,
                    alerta: retrasada,
                  ),
                  const SizedBox(width: AppEspacios.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (retrasada || reserva.reprogramaciones > 0)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppEspacios.xs,
                            ),
                            child: Wrap(
                              spacing: AppEspacios.xs,
                              runSpacing: AppEspacios.xs,
                              children: [
                                if (noLlego)
                                  EtiquetaEstado(
                                    icono: Icons.event_busy,
                                    texto: l10n.reservaNoLlego,
                                    tono: TonoEtiqueta.aviso,
                                  )
                                else if (retrasada)
                                  EtiquetaEstado(
                                    icono: Icons.schedule,
                                    texto: l10n.reservaRetrasada,
                                    tono: TonoEtiqueta.aviso,
                                  ),
                                if (reserva.reprogramaciones > 0)
                                  EtiquetaEstado(
                                    icono: Icons.update,
                                    texto: l10n.reservaReprogramada,
                                  ),
                              ],
                            ),
                          ),
                        Text(reserva.nombreContacto, style: textos.titleSmall),
                        Text(
                          l10n.personas(reserva.personas),
                          style: textos.bodyMedium?.copyWith(
                            color: esquema.onSurfaceVariant,
                          ),
                        ),
                        if (telefono != null)
                          Text(
                            l10n.reservaTelefono(telefono),
                            style: textos.bodyMedium?.copyWith(
                              color: esquema.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppEspacios.m),
            if (esperadaHoy) ...[
              FilledButton.icon(
                onPressed: llegaron,
                icon: const Icon(Icons.how_to_reg),
                label: Text(l10n.reservaLlegaron),
              ),
              const SizedBox(height: AppEspacios.s),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: compacto,
                    onPressed: () => context.push<void>(
                      Rutas.reprogramarReserva(reserva.id),
                    ),
                    icon: const Icon(Icons.edit_calendar, size: 20),
                    label: Text(l10n.reservaReprogramar),
                  ),
                ),
                const SizedBox(width: AppEspacios.s),
                Expanded(
                  child: OutlinedButton.icon(
                    style: compacto,
                    onPressed: cancelar,
                    icon: const Icon(Icons.event_busy, size: 20),
                    label: Text(l10n.reservaCancelar),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Hora de llegada, visible de un vistazo. Si la reserva era de otro día,
/// también muestra la fecha.
class _Hora extends StatelessWidget {
  const _Hora({required this.hora, required this.alerta, this.fecha});

  final String hora;
  final String? fecha;
  final bool alerta;

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquema;
    final colores = context.colores;
    final textos = context.textos;
    final fecha = this.fecha;
    final fondo = alerta ? colores.aviso : esquema.primaryContainer;
    final frente = alerta ? colores.sobreAviso : esquema.onPrimaryContainer;

    // Con letra grande, "10:30 AM" no debe aplastar el nombre: si no cabe
    // en el ancho máximo, se achica.
    return Container(
      constraints: const BoxConstraints(minWidth: 64, maxWidth: 104),
      padding: const EdgeInsets.symmetric(
        horizontal: AppEspacios.s,
        vertical: AppEspacios.s,
      ),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(AppEspacios.radioChico),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          children: [
            if (fecha != null)
              Text(fecha, style: textos.labelSmall?.copyWith(color: frente)),
            Text(hora, style: textos.titleMedium?.copyWith(color: frente)),
          ],
        ),
      ),
    );
  }
}
