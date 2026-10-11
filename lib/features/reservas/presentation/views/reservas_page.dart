import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/router/rutas.dart';
import '../../../../core/theme/app_espacios.dart';
import '../../../../core/theme/colores_app.dart';
import '../../../../shared/widgets/acciones_barra.dart';
import '../../../../shared/widgets/estado_vacio.dart';
import '../../../../shared/widgets/titulo_seccion.dart';
import '../../../sesion/presentation/views/boton_sesion.dart';
import '../../domain/agenda_reservas.dart';
import '../../domain/reserva.dart';
import '../view_models/reservas_view_model.dart';
import 'tarjeta_reserva.dart';
import 'textos_reserva.dart';

/// Agenda de reservas del puesto de control: las que no llegaron, las de
/// hoy y las de los próximos días, cada día con cuántas personas se esperan.
class ReservasPage extends ConsumerWidget {
  const ReservasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final agenda = ref.watch(agendaReservasProvider);
    final ahora = agenda.ahora;

    List<Widget> tarjetas(Iterable<Reserva> reservas) => [
      for (final reserva in reservas)
        Padding(
          padding: const EdgeInsets.only(bottom: AppEspacios.m),
          child: TarjetaReserva(reserva: reserva, ahora: ahora),
        ),
    ];

    List<Widget> dia(DiaDeReservas dia) => [
      TituloSeccion(
        l10n.reservasDia(textoDia(context, dia.dia, ahora), dia.personas),
      ),
      ...tarjetas(dia.reservas),
    ];

    return Scaffold(
      appBar: BarraAsociacion(
        titulo: l10n.reservasTitulo,
        acciones: const [BotonSesion()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push<void>(Rutas.reservaNueva),
        icon: const Icon(Icons.add),
        label: Text(l10n.reservasNueva),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppEspacios.l,
          0,
          AppEspacios.l,
          AppEspacios.bajoBotonFlotante,
        ),
        children: [
          if (agenda.vacia)
            Padding(
              padding: const EdgeInsets.only(top: AppEspacios.xl),
              child: EstadoVacio(
                icono: Icons.event_available_outlined,
                titulo: l10n.reservasVacio,
                detalle: l10n.reservasVacioDetalle,
              ),
            ),
          if (agenda.sinLlegar.isNotEmpty) ...[
            TituloSeccion(l10n.reservasSinLlegar),
            Padding(
              padding: const EdgeInsets.only(bottom: AppEspacios.m),
              child: Text(
                l10n.reservasSinLlegarDetalle,
                style: context.textos.bodyMedium?.copyWith(
                  color: context.esquema.onSurfaceVariant,
                ),
              ),
            ),
            ...tarjetas(agenda.sinLlegar),
          ],
          if (agenda.deHoy.reservas.isNotEmpty) ...dia(agenda.deHoy),
          for (final proximo in agenda.proximas) ...dia(proximo),
        ],
      ),
    );
  }
}
