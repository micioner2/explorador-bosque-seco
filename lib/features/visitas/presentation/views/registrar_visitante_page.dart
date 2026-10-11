import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/etiquetas_dominio.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_espacios.dart';
import '../../../../core/theme/colores_app.dart';
import '../../../../shared/widgets/acciones_barra.dart';
import '../../../../shared/widgets/etiqueta_estado.dart';
import '../../../../shared/widgets/icono_circular.dart';
import '../../../../shared/widgets/titulo_seccion.dart';
import '../../../reservas/domain/reserva.dart';
import '../../../sesion/presentation/view_models/sesion_view_model.dart';
import '../../../sesion/presentation/views/boton_sesion.dart';
import '../../domain/visita.dart';
import '../view_models/registro_grupo_view_model.dart';
import 'qr_grupo_dialog.dart';

/// Registro de un grupo en una sola pantalla (reemplaza al cuaderno).
///
/// El encargado agrega a cada integrante con su nombre, edad y procedencia,
/// elige una o varias actividades para todo el grupo y, al registrar, se
/// genera un único QR que todos escanean.
class RegistrarVisitantePage extends ConsumerStatefulWidget {
  const RegistrarVisitantePage({super.key});

  @override
  ConsumerState<RegistrarVisitantePage> createState() =>
      _RegistrarVisitantePageState();
}

class _RegistrarVisitantePageState
    extends ConsumerState<RegistrarVisitantePage> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _edad = TextEditingController();
  final _focoNombre = FocusNode();
  Procedencia _procedencia = Procedencia.piura;
  bool _faltaActividad = false;

  RegistroGrupoViewModel get _viewModel =>
      ref.read(registroGrupoViewModelProvider.notifier);

  bool get _hayDatosSinAgregar =>
      _nombre.text.trim().isNotEmpty || _edad.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _proponerNombre(ref.read(reservaEnAtencionProvider));
  }

  /// Quien reservó suele ser el responsable del grupo: se propone su nombre
  /// para el primer integrante (se puede cambiar).
  void _proponerNombre(Reserva? reserva) {
    if (reserva == null) return;
    final sinEmpezar =
        _nombre.text.trim().isEmpty &&
        ref.read(registroGrupoViewModelProvider).integrantes.isEmpty;
    if (sinEmpezar) _nombre.text = reserva.nombreContacto;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _edad.dispose();
    _focoNombre.dispose();
    super.dispose();
  }

  /// Pasa lo escrito a la lista del grupo. Devuelve `false` si falta algo.
  /// La procedencia se conserva: en un grupo suele repetirse.
  bool _agregarIntegrante() {
    if (!(_formKey.currentState?.validate() ?? false)) return false;
    _viewModel.agregarIntegrante(
      nombre: _nombre.text,
      edad: int.parse(_edad.text),
      procedencia: _procedencia,
    );
    _formKey.currentState?.reset();
    _nombre.clear();
    _edad.clear();
    return true;
  }

  void _alTocarAgregar() {
    if (_agregarIntegrante()) _focoNombre.requestFocus();
  }

  Future<void> _registrar() async {
    final sinIntegrantes = ref
        .read(registroGrupoViewModelProvider)
        .integrantes
        .isEmpty;
    // Lo que quedó escrito sin agregar también cuenta como integrante.
    if ((_hayDatosSinAgregar || sinIntegrantes) && !_agregarIntegrante()) {
      return;
    }
    if (!ref.read(registroGrupoViewModelProvider).completo) {
      setState(() => _faltaActividad = true);
      return;
    }
    FocusScope.of(context).unfocus();
    final visita = _viewModel.registrar();
    await mostrarQrGrupo(context, visita);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final esquema = context.esquema;
    final textos = context.textos;
    final borrador = ref.watch(registroGrupoViewModelProvider);
    final guia = ref.watch(sesionViewModelProvider.select((s) => s.guia));
    final reserva = ref.watch(reservaEnAtencionProvider);
    // La pantalla puede estar abierta en otra pestaña cuando llega el grupo.
    ref.listen(reservaEnAtencionProvider, (antes, ahora) {
      if (ahora?.id != antes?.id) _proponerNombre(ahora);
    });

    return Scaffold(
      appBar: BarraAsociacion(
        titulo: l10n.registrarTitulo,
        acciones: const [BotonSesion()],
      ),
      // No es una lista perezosa: un formulario necesita todos sus campos
      // vivos para validarlos aunque hayan quedado fuera de la pantalla.
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
            if (guia != null)
              Padding(
                padding: const EdgeInsets.only(top: AppEspacios.l),
                child: _QuienRegistra(
                  nombre: guia.nombre,
                  onCambiar: ref
                      .read(sesionViewModelProvider.notifier)
                      .cambiarGuia,
                ),
              ),
            if (reserva != null)
              Padding(
                padding: const EdgeInsets.only(top: AppEspacios.s),
                child: _LlegadaDeReserva(
                  reserva: reserva,
                  onQuitar: _viewModel.soltarReserva,
                ),
              ),
            TituloSeccion(
              reserva == null
                  ? l10n.registrarIntegrantes(borrador.integrantes.length)
                  : l10n.registrarIntegrantesDe(
                      borrador.integrantes.length,
                      reserva.personas,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: AppEspacios.m),
              child: Text(
                l10n.registrarAyuda,
                style: textos.bodyMedium?.copyWith(
                  color: esquema.onSurfaceVariant,
                ),
              ),
            ),
            for (final (indice, integrante) in borrador.integrantes.indexed)
              _FilaIntegrante(
                orden: indice + 1,
                integrante: integrante,
                onQuitar: () => _viewModel.quitarIntegrante(integrante),
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppEspacios.m),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nombre,
                        focusNode: _focoNombre,
                        decoration: InputDecoration(
                          labelText: l10n.registrarNombre,
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
                        controller: _edad,
                        decoration: InputDecoration(
                          labelText: l10n.registrarEdad,
                          prefixIcon: const Icon(Icons.cake_outlined),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        onFieldSubmitted: (_) => _alTocarAgregar(),
                        validator: (valor) {
                          final edad = int.tryParse(valor ?? '');
                          if (edad == null) return l10n.validarEdadNumero;
                          if (edad < 0 || edad > 120) {
                            return l10n.validarEdadRango;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppEspacios.m),
                      Text(l10n.registrarProcedencia, style: textos.labelLarge),
                      const SizedBox(height: AppEspacios.xs),
                      Wrap(
                        spacing: AppEspacios.s,
                        children: [
                          for (final procedencia in Procedencia.values)
                            ChoiceChip(
                              label: Text(procedencia.texto(l10n)),
                              selected: _procedencia == procedencia,
                              onSelected: (_) =>
                                  setState(() => _procedencia = procedencia),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppEspacios.m),
                      OutlinedButton.icon(
                        onPressed: _alTocarAgregar,
                        icon: const Icon(Icons.person_add_alt_1_outlined),
                        label: Text(l10n.registrarAgregarIntegrante),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            TituloSeccion(l10n.registrarActividades),
            Text(
              l10n.registrarActividadesAyuda,
              style: textos.bodyMedium?.copyWith(
                color: esquema.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppEspacios.s),
            Wrap(
              spacing: AppEspacios.s,
              children: [
                for (final actividad in Actividad.values)
                  FilterChip(
                    label: Text(actividad.texto(l10n)),
                    selected: borrador.actividades.contains(actividad),
                    onSelected: (_) {
                      _viewModel.alternarActividad(actividad);
                      setState(() => _faltaActividad = false);
                    },
                  ),
              ],
            ),
            if (_faltaActividad && borrador.actividades.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppEspacios.xs),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    l10n.validarActividad,
                    style: textos.bodyMedium?.copyWith(color: esquema.error),
                  ),
                ),
              ),
            const SizedBox(height: AppEspacios.xl),
            FilledButton.icon(
              onPressed: _registrar,
              icon: const Icon(Icons.qr_code_2),
              label: Text(l10n.registrarBoton),
            ),
          ],
        ),
      ),
    );
  }
}

/// Guía a cuyo nombre quedará el grupo. Si otro guía toma el celular, lo
/// cambia aquí mismo.
class _QuienRegistra extends StatelessWidget {
  const _QuienRegistra({required this.nombre, required this.onCambiar});

  final String nombre;
  final VoidCallback onCambiar;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final esquema = context.esquema;
    final textos = context.textos;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppEspacios.m,
          AppEspacios.s,
          AppEspacios.xs,
          AppEspacios.s,
        ),
        child: Row(
          children: [
            const IconoCircular(Icons.badge_outlined, lado: 40),
            const SizedBox(width: AppEspacios.m),
            Expanded(
              child: MergeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.registrarComo,
                      style: textos.labelMedium?.copyWith(
                        color: esquema.onSurfaceVariant,
                      ),
                    ),
                    Text(nombre, style: textos.titleSmall),
                  ],
                ),
              ),
            ),
            TextButton(
              onPressed: onCambiar,
              child: Text(l10n.cambiar, semanticsLabel: l10n.sesionCambiarGuia),
            ),
          ],
        ),
      ),
    );
  }
}

/// El grupo llegó con reserva: al registrarlo, la reserva queda como su
/// ingreso. Si no es ese grupo, se quita y se registra sin reserva.
class _LlegadaDeReserva extends StatelessWidget {
  const _LlegadaDeReserva({required this.reserva, required this.onQuitar});

  final Reserva reserva;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final esquema = context.esquema;
    final textos = context.textos;

    return Card(
      color: esquema.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppEspacios.m,
          AppEspacios.s,
          AppEspacios.xs,
          AppEspacios.s,
        ),
        child: Row(
          children: [
            Icon(Icons.event_available, color: esquema.onPrimaryContainer),
            const SizedBox(width: AppEspacios.m),
            Expanded(
              child: MergeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.registrarReserva,
                      style: textos.labelMedium?.copyWith(
                        color: esquema.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      l10n.registrarReservaDetalle(
                        reserva.nombreContacto,
                        reserva.personas,
                      ),
                      style: textos.titleSmall?.copyWith(
                        color: esquema.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TextButton(
              onPressed: onQuitar,
              child: Text(
                l10n.quitar,
                semanticsLabel: l10n.registrarSinReserva,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Integrante ya agregado al grupo, con la opción de quitarlo.
class _FilaIntegrante extends StatelessWidget {
  const _FilaIntegrante({
    required this.orden,
    required this.integrante,
    required this.onQuitar,
  });

  final int orden;
  final Visitante integrante;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final esquema = context.esquema;
    final textos = context.textos;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppEspacios.s),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.only(
            left: AppEspacios.m,
            top: AppEspacios.xs,
            bottom: AppEspacios.xs,
          ),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: esquema.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$orden',
                    style: textos.labelLarge?.copyWith(
                      color: esquema.onPrimaryContainer,
                    ),
                    textScaler: TextScaler.noScaling,
                  ),
                ),
              ),
              const SizedBox(width: AppEspacios.m),
              Expanded(
                child: MergeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: AppEspacios.s,
                        runSpacing: AppEspacios.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(integrante.nombre, style: textos.titleSmall),
                          if (orden == 1)
                            EtiquetaEstado(
                              texto: l10n.registrarResponsable,
                              tono: TonoEtiqueta.exito,
                            ),
                        ],
                      ),
                      Text(
                        l10n.registrarIntegranteDetalle(
                          integrante.edad,
                          integrante.procedencia.texto(l10n),
                        ),
                        style: textos.bodyMedium?.copyWith(
                          color: esquema.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.registrarQuitarIntegrante(integrante.nombre),
                onPressed: onQuitar,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
