import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/formato.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/reloj.dart';
import '../../../../core/theme/app_espacios.dart';
import '../../../../core/theme/colores_app.dart';
import '../../../../shared/widgets/acciones_barra.dart';
import '../../../../shared/widgets/estado_vacio.dart';
import '../../../../shared/widgets/titulo_seccion.dart';
import '../../domain/reserva.dart';
import '../view_models/reservas_view_model.dart';
import 'textos_reserva.dart';

/// Anota una reserva nueva o reprograma una existente ([reservaId]).
///
/// Pensada para anotar rápido mientras se habla por teléfono: el día se
/// elige con un toque ("Hoy", "Mañana" u "Otro día"), la hora viene
/// sugerida y las personas se suman con botones grandes. Un resumen dice
/// cómo quedará antes de guardar.
class FormularioReservaPage extends ConsumerStatefulWidget {
  const FormularioReservaPage({super.key, this.reservaId});

  /// Reserva a reprogramar; `null` para anotar una nueva.
  final String? reservaId;

  @override
  ConsumerState<FormularioReservaPage> createState() =>
      _FormularioReservaPageState();
}

class _FormularioReservaPageState extends ConsumerState<FormularioReservaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _telefono = TextEditingController();
  late final DateTime _hoy;
  late final Reserva? _original;
  late DateTime _dia;
  late TimeOfDay _hora;
  late int _personas;
  bool _horaPasada = false;

  @override
  void initState() {
    super.initState();
    final ahora = ref.read(relojProvider)();
    _hoy = DateUtils.dateOnly(ahora);
    final id = widget.reservaId;
    final original = id == null
        ? null
        : ref.read(reservasViewModelProvider.notifier).buscar(id);
    _original = (original != null && original.pendiente) ? original : null;

    // Una reserva nueva sugiere la próxima hora en punto.
    final base =
        _original?.fechaHora ??
        DateTime(ahora.year, ahora.month, ahora.day, ahora.hour + 1);
    final diaBase = DateUtils.dateOnly(base);
    // Si el grupo no llegó un día anterior, se reprograma desde hoy.
    _dia = diaBase.isBefore(_hoy) ? _hoy : diaBase;
    _hora = TimeOfDay.fromDateTime(base);
    _personas = _original?.personas ?? 2;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    super.dispose();
  }

  DateTime get _fechaHora =>
      DateTime(_dia.year, _dia.month, _dia.day, _hora.hour, _hora.minute);

  void _elegirDia(DateTime dia) => setState(() {
    _dia = DateUtils.dateOnly(dia);
    _horaPasada = false;
  });

  Future<void> _elegirOtroDia() async {
    final elegido = await showDatePicker(
      context: context,
      initialDate: _dia,
      firstDate: _hoy,
      lastDate: DateUtils.addDaysToDate(_hoy, 365),
      helpText: context.l10n.reservaDia,
    );
    if (elegido != null) _elegirDia(elegido);
  }

  Future<void> _elegirHora() async {
    final elegida = await showTimePicker(
      context: context,
      initialTime: _hora,
      helpText: context.l10n.reservaHora,
    );
    if (elegida == null) return;
    setState(() {
      _hora = elegida;
      _horaPasada = false;
    });
  }

  void _guardar() {
    final l10n = context.l10n;
    final datosCompletos = _formKey.currentState?.validate() ?? true;
    final fechaHora = _fechaHora;
    final horaPasada = !Reserva.fechaValida(
      fechaHora,
      ref.read(relojProvider)(),
    );
    setState(() => _horaPasada = horaPasada);
    if (!datosCompletos || horaPasada) return;

    final viewModel = ref.read(reservasViewModelProvider.notifier);
    final original = _original;
    final reserva = original == null
        ? viewModel.crear(
            nombreContacto: _nombre.text,
            telefono: _telefono.text,
            fechaHora: fechaHora,
            personas: _personas,
          )
        : viewModel.reprogramar(
            original.id,
            fechaHora: fechaHora,
            personas: _personas,
          );
    final cuando = textoCuando(context, reserva.fechaHora, _hoy);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            original == null
                ? l10n.reservaGuardada(reserva.nombreContacto, cuando)
                : l10n.reservaReprogramadaAviso(reserva.nombreContacto, cuando),
          ),
        ),
      );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final esquema = context.esquema;
    final textos = context.textos;
    final original = _original;
    final titulo = widget.reservaId == null
        ? l10n.reservasNueva
        : l10n.reservaReprogramarTitulo;

    if (widget.reservaId != null && original == null) {
      return Scaffold(
        appBar: BarraAsociacion(titulo: titulo),
        body: EstadoVacio(
          icono: Icons.event_busy,
          titulo: l10n.reservaNoExiste,
        ),
      );
    }

    final manana = DateUtils.addDaysToDate(_hoy, 1);
    final esHoy = DateUtils.isSameDay(_dia, _hoy);
    final esManana = DateUtils.isSameDay(_dia, manana);
    final otroDia = !esHoy && !esManana;

    return Scaffold(
      appBar: BarraAsociacion(titulo: titulo),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppEspacios.l,
          0,
          AppEspacios.l,
          AppEspacios.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (original != null)
              Padding(
                padding: const EdgeInsets.only(top: AppEspacios.l),
                child: _ReservaOriginal(reserva: original, hoy: _hoy),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: AppEspacios.l),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nombre,
                        decoration: InputDecoration(
                          labelText: l10n.reservaNombre,
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        validator: (valor) =>
                            (valor == null || valor.trim().isEmpty)
                            ? l10n.validarNombre
                            : null,
                      ),
                      const SizedBox(height: AppEspacios.m),
                      TextFormField(
                        controller: _telefono,
                        decoration: InputDecoration(
                          labelText: l10n.reservaCelular,
                          prefixIcon: const Icon(Icons.phone_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9 +]')),
                          LengthLimitingTextInputFormatter(15),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            TituloSeccion(l10n.reservaDia),
            Wrap(
              spacing: AppEspacios.s,
              runSpacing: AppEspacios.s,
              children: [
                ChoiceChip(
                  label: Text(l10n.diaHoy),
                  selected: esHoy,
                  onSelected: (_) => _elegirDia(_hoy),
                ),
                ChoiceChip(
                  label: Text(l10n.diaManana),
                  selected: esManana,
                  onSelected: (_) => _elegirDia(manana),
                ),
                ChoiceChip(
                  avatar: const Icon(Icons.calendar_month_outlined),
                  label: Text(
                    otroDia
                        ? formatearFechaCorta(_dia, l10n.localeName)
                        : l10n.reservaOtroDia,
                  ),
                  selected: otroDia,
                  onSelected: (_) => _elegirOtroDia(),
                ),
              ],
            ),
            TituloSeccion(l10n.reservaHora),
            OutlinedButton.icon(
              onPressed: _elegirHora,
              icon: const Icon(Icons.schedule),
              label: Text(_hora.format(context)),
            ),
            if (_horaPasada)
              Padding(
                padding: const EdgeInsets.only(top: AppEspacios.xs),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    l10n.validarHoraPasada,
                    style: textos.bodyMedium?.copyWith(color: esquema.error),
                  ),
                ),
              ),
            TituloSeccion(l10n.reservaPersonasPregunta),
            _Contador(
              personas: _personas,
              onMenos: _personas > 1 ? () => setState(() => _personas--) : null,
              onMas: _personas < Reserva.maxPersonas
                  ? () => setState(() => _personas++)
                  : null,
            ),
            const SizedBox(height: AppEspacios.xl),
            _Resumen(
              texto: l10n.reservaResumen(
                textoCuando(context, _fechaHora, _hoy),
                _personas,
              ),
            ),
            const SizedBox(height: AppEspacios.m),
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.event_available),
              label: Text(
                original == null
                    ? l10n.reservaGuardar
                    : l10n.reservaGuardarCambios,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quién reservó y para cuándo era, al reprogramar.
class _ReservaOriginal extends StatelessWidget {
  const _ReservaOriginal({required this.reserva, required this.hoy});

  final Reserva reserva;
  final DateTime hoy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final esquema = context.esquema;
    final textos = context.textos;
    final telefono = reserva.telefono;
    final secundario = textos.bodyMedium?.copyWith(
      color: esquema.onSurfaceVariant,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppEspacios.m),
        child: MergeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(reserva.nombreContacto, style: textos.titleSmall),
              if (telefono != null)
                Text(l10n.reservaTelefono(telefono), style: secundario),
              Text(
                l10n.reservaAntes(
                  l10n.reservaResumen(
                    textoCuando(context, reserva.fechaHora, hoy),
                    reserva.personas,
                  ),
                ),
                style: secundario,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cantidad de personas con botones grandes para restar y sumar.
class _Contador extends StatelessWidget {
  const _Contador({
    required this.personas,
    required this.onMenos,
    required this.onMas,
  });

  final int personas;
  final VoidCallback? onMenos;
  final VoidCallback? onMas;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        IconButton.filledTonal(
          tooltip: l10n.reservaMenos,
          iconSize: 28,
          onPressed: onMenos,
          icon: const Icon(Icons.remove),
        ),
        Expanded(
          child: Semantics(
            liveRegion: true,
            child: Text(
              l10n.personas(personas),
              textAlign: TextAlign.center,
              style: context.textos.headlineSmall,
            ),
          ),
        ),
        IconButton.filledTonal(
          tooltip: l10n.reservaMas,
          iconSize: 28,
          onPressed: onMas,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

/// Cómo quedará la reserva, para confirmarlo de un vistazo antes de
/// guardar.
class _Resumen extends StatelessWidget {
  const _Resumen({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquema;

    return Container(
      padding: const EdgeInsets.all(AppEspacios.m),
      decoration: BoxDecoration(
        color: esquema.primaryContainer,
        borderRadius: BorderRadius.circular(AppEspacios.radioChico),
      ),
      child: Row(
        children: [
          Icon(Icons.event_note_outlined, color: esquema.onPrimaryContainer),
          const SizedBox(width: AppEspacios.m),
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Text(
                texto,
                style: context.textos.titleSmall?.copyWith(
                  color: esquema.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
