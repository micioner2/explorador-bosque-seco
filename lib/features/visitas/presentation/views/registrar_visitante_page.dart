import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/visita.dart';
import '../view_models/visitas_view_model.dart';

/// Formulario corto para registrar al visitante (reemplaza al cuaderno).
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
  Procedencia _procedencia = Procedencia.piura;
  Actividad _actividad = Actividad.senderismo;
  int _grupo = 1;

  @override
  void dispose() {
    _nombre.dispose();
    _edad.dispose();
    super.dispose();
  }

  void _registrar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final visita = ref
        .read(visitasViewModelProvider.notifier)
        .registrar(
          nombreResponsable: _nombre.text,
          edad: int.parse(_edad.text),
          procedencia: _procedencia,
          tamanoGrupo: _grupo,
          actividad: _actividad,
        );
    _formKey.currentState?.reset();
    _nombre.clear();
    _edad.clear();
    setState(() => _grupo = 1);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Visita de ${visita.nombreResponsable} registrada'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar visitante')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombre,
              decoration: const InputDecoration(
                labelText: 'Nombre del responsable',
              ),
              textCapitalization: TextCapitalization.words,
              validator: _validarNombre,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _edad,
              decoration: const InputDecoration(labelText: 'Edad'),
              keyboardType: TextInputType.number,
              validator: _validarEdad,
            ),
            const SizedBox(height: 16),
            const Text('Procedencia'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in Procedencia.values)
                  ChoiceChip(
                    label: Text(p.etiqueta),
                    selected: _procedencia == p,
                    onSelected: (_) => setState(() => _procedencia = p),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(child: Text('Personas en el grupo')),
                IconButton.filledTonal(
                  tooltip: 'Quitar una persona',
                  onPressed: _grupo > 1 ? () => setState(() => _grupo--) : null,
                  icon: const Icon(Icons.remove),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '$_grupo',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Agregar una persona',
                  onPressed: () => setState(() => _grupo++),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Actividad>(
              initialValue: _actividad,
              decoration: const InputDecoration(labelText: 'Actividad'),
              items: [
                for (final a in Actividad.values)
                  DropdownMenuItem(value: a, child: Text(a.etiqueta)),
              ],
              onChanged: (a) => setState(() => _actividad = a ?? _actividad),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _registrar,
              child: const Text('Registrar y generar QR'),
            ),
          ],
        ),
      ),
    );
  }

  static String? _validarNombre(String? valor) =>
      (valor == null || valor.trim().isEmpty) ? 'Ingresa el nombre' : null;

  static String? _validarEdad(String? valor) {
    final edad = int.tryParse(valor ?? '');
    if (edad == null) return 'Ingresa la edad en números';
    if (edad < 0 || edad > 120) return 'Edad fuera de rango';
    return null;
  }
}
