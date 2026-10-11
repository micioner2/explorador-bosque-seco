import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_espacios.dart';
import '../../../../core/theme/colores_app.dart';
import '../../../../shared/widgets/acciones_barra.dart';
import '../../../../shared/widgets/icono_circular.dart';
import '../../../../shared/widgets/logo_app.dart';
import '../../domain/resultado_acceso.dart';
import '../view_models/acceso_view_model.dart';
import '../view_models/sesion_view_model.dart';
import 'cabecera_acceso.dart';

/// Paso 1 para entrar al puesto de control: la cuenta de la asociación.
///
/// Pensada para personas con poca experiencia en el celular: dos campos,
/// un botón grande, mensajes que dicen qué hacer y la tranquilidad de que
/// solo la primera vez hace falta señal. Al entrar, el router lleva solo
/// al paso 2 ("¿Quién eres?").
class AccesoPage extends ConsumerStatefulWidget {
  const AccesoPage({super.key});

  @override
  ConsumerState<AccesoPage> createState() => _AccesoPageState();
}

class _AccesoPageState extends ConsumerState<AccesoPage> {
  final _formKey = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _clave = TextEditingController();
  bool _verClave = false;

  @override
  void dispose() {
    _correo.dispose();
    _clave.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final mensajero = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final entro = await ref
        .read(accesoViewModelProvider.notifier)
        .entrar(correo: _correo.text, clave: _clave.text);
    final cuenta = ref.read(sesionViewModelProvider).cuenta;
    if (entro && cuenta != null) {
      mensajero.showSnackBar(
        SnackBar(content: Text(l10n.accesoBienvenida(cuenta.nombreAsociacion))),
      );
    }
    // Ofrece guardar la contraseña en el celular para la próxima vez.
    if (entro) TextInput.finishAutofillContext();
  }

  /// Un solo toque: llena la cuenta de prueba y entra.
  Future<void> _usarCuentaDemo(({String correo, String clave}) cuenta) {
    _correo.text = cuenta.correo;
    _clave.text = cuenta.clave;
    return _entrar();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final estado = ref.watch(accesoViewModelProvider);
    final rechazo = estado.rechazo;
    final cuentaDemo = estado.cuentaDemo;
    final entrando = estado.entrando;

    return Scaffold(
      appBar: BarraAsociacion(titulo: l10n.modoAsociacion),
      // No es una lista perezosa: el formulario necesita todos sus campos
      // vivos para validarlos.
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppEspacios.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CabeceraAcceso(
              paso: 1,
              icono: Icons.storefront_outlined,
              titulo: l10n.accesoTitulo,
              detalle: l10n.accesoSubtitulo,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppEspacios.l,
                AppEspacios.l,
                AppEspacios.l,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppEspacios.l),
                  const LogoApp(),
                  const SizedBox(height: AppEspacios.l),
                  if (rechazo != null) ...[
                    _AvisoRechazo(motivo: rechazo.motivo),
                    const SizedBox(height: AppEspacios.m),
                  ],
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppEspacios.l),
                      child: Form(
                        key: _formKey,
                        child: AutofillGroup(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _correo,
                                enabled: !entrando,
                                decoration: InputDecoration(
                                  labelText: l10n.accesoCorreo,
                                  prefixIcon: const Icon(Icons.mail_outline),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [
                                  AutofillHints.email,
                                  AutofillHints.username,
                                ],
                                autocorrect: false,
                                enableSuggestions: false,
                                textInputAction: TextInputAction.next,
                                validator: (valor) {
                                  final correo = valor?.trim() ?? '';
                                  if (correo.isEmpty) return l10n.validarCorreo;
                                  if (!correo.contains('@')) {
                                    return l10n.validarCorreoFormato;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppEspacios.m),
                              TextFormField(
                                controller: _clave,
                                enabled: !entrando,
                                obscureText: !_verClave,
                                decoration: InputDecoration(
                                  labelText: l10n.accesoClave,
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    tooltip: _verClave
                                        ? l10n.accesoOcultarClave
                                        : l10n.accesoMostrarClave,
                                    icon: Icon(
                                      _verClave
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                    onPressed: () =>
                                        setState(() => _verClave = !_verClave),
                                  ),
                                ),
                                autofillHints: const [AutofillHints.password],
                                autocorrect: false,
                                enableSuggestions: false,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _entrar(),
                                validator: (valor) =>
                                    (valor == null || valor.isEmpty)
                                    ? l10n.validarClave
                                    : null,
                              ),
                              const SizedBox(height: AppEspacios.l),
                              FilledButton.icon(
                                onPressed: entrando ? null : _entrar,
                                icon: entrando
                                    ? const _Girando()
                                    : const Icon(Icons.login),
                                label: Text(
                                  entrando
                                      ? l10n.accesoEntrando
                                      : l10n.accesoEntrar,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (cuentaDemo != null) ...[
                    const SizedBox(height: AppEspacios.m),
                    _TarjetaDemo(
                      cuenta: cuentaDemo,
                      onUsar: entrando
                          ? null
                          : () => _usarCuentaDemo(cuentaDemo),
                    ),
                  ],
                  const SizedBox(height: AppEspacios.xl),
                  _Nota(
                    icono: Icons.wifi_off,
                    titulo: l10n.accesoSinSenalTitulo,
                    detalle: l10n.accesoSinSenalDetalle,
                  ),
                  const SizedBox(height: AppEspacios.l),
                  _Nota(icono: Icons.help_outline, detalle: l10n.accesoOlvido),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Indicador de espera dentro del botón "Entrar".
class _Girando extends StatelessWidget {
  const _Girando();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: context.esquema.onSurfaceVariant,
      ),
    );
  }
}

/// Por qué no se pudo entrar y qué hacer. Se anuncia en el lector de
/// pantalla apenas aparece. La falta de señal no es un error de la persona:
/// se muestra como aviso, no en rojo.
class _AvisoRechazo extends StatelessWidget {
  const _AvisoRechazo({required this.motivo});

  final MotivoRechazo motivo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final esquema = context.esquema;
    final colores = context.colores;
    final textos = context.textos;

    final (icono, titulo, detalle, esAviso) = switch (motivo) {
      MotivoRechazo.credencialesIncorrectas => (
        Icons.key_off_outlined,
        l10n.accesoRechazoCredenciales,
        l10n.accesoRechazoCredencialesDetalle,
        false,
      ),
      MotivoRechazo.cuentaNoHabilitada => (
        Icons.no_accounts_outlined,
        l10n.accesoRechazoCuenta,
        l10n.accesoRechazoCuentaDetalle,
        false,
      ),
      MotivoRechazo.sinConexion => (
        Icons.wifi_off,
        l10n.accesoRechazoSinConexion,
        l10n.accesoRechazoSinConexionDetalle,
        true,
      ),
      MotivoRechazo.demasiadosIntentos => (
        Icons.hourglass_bottom,
        l10n.accesoRechazoIntentos,
        l10n.accesoRechazoIntentosDetalle,
        true,
      ),
      MotivoRechazo.errorDelServidor => (
        Icons.error_outline,
        l10n.accesoRechazoServidor,
        l10n.accesoRechazoServidorDetalle,
        false,
      ),
    };
    final fondo = esAviso ? colores.aviso : esquema.errorContainer;
    final frente = esAviso ? colores.sobreAviso : esquema.onErrorContainer;

    return Semantics(
      liveRegion: true,
      child: MergeSemantics(
        child: Container(
          decoration: BoxDecoration(
            color: fondo,
            borderRadius: BorderRadius.circular(AppEspacios.radioChico),
          ),
          padding: const EdgeInsets.all(AppEspacios.m),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icono, color: frente),
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
        ),
      ),
    );
  }
}

/// Cuenta de prueba, solo cuando la app no tiene servidor (demostraciones).
class _TarjetaDemo extends StatelessWidget {
  const _TarjetaDemo({required this.cuenta, required this.onUsar});

  final ({String correo, String clave}) cuenta;
  final VoidCallback? onUsar;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final esquema = context.esquema;
    final textos = context.textos;

    return Card(
      color: esquema.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(AppEspacios.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.accesoDemoTitulo, style: textos.titleSmall),
                  const SizedBox(height: AppEspacios.xs),
                  Text(
                    l10n.accesoDemoDetalle(cuenta.correo, cuenta.clave),
                    style: textos.bodyMedium?.copyWith(
                      color: esquema.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppEspacios.m),
            OutlinedButton.icon(
              onPressed: onUsar,
              icon: const Icon(Icons.person_search_outlined),
              label: Text(l10n.accesoDemoUsar),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nota de ayuda con su icono.
class _Nota extends StatelessWidget {
  const _Nota({required this.icono, required this.detalle, this.titulo});

  final IconData icono;
  final String? titulo;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquema;
    final textos = context.textos;
    final titulo = this.titulo;

    return MergeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconoCircular(icono, lado: 40),
          const SizedBox(width: AppEspacios.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (titulo != null) Text(titulo, style: textos.titleSmall),
                Text(
                  detalle,
                  style: textos.bodyMedium?.copyWith(
                    color: esquema.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
