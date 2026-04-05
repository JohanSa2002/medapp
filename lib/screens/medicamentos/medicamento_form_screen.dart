import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/medicamento.dart';
import '../../providers/medicamento_provider.dart';
import '../../providers/notification_provider.dart';

class MedicamentoFormScreen extends StatefulWidget {
  final String userId;
  final Medicamento? medicamento;

  const MedicamentoFormScreen({
    super.key,
    required this.userId,
    this.medicamento,
  });

  @override
  State<MedicamentoFormScreen> createState() => _MedicamentoFormScreenState();
}

class _MedicamentoFormScreenState extends State<MedicamentoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _dosisController;
  late final TextEditingController _notasController;
  final TextEditingController _horarioController = TextEditingController();

  List<String> _horarios = [];
  bool _isLoading = false;

  bool get _isEditing => widget.medicamento != null;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.medicamento?.nombre ?? '');
    _dosisController = TextEditingController(text: widget.medicamento?.dosis ?? '');
    _notasController = TextEditingController(text: widget.medicamento?.notas ?? '');
    _horarios = List<String>.from(widget.medicamento?.horarios ?? []);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _dosisController.dispose();
    _notasController.dispose();
    _horarioController.dispose();
    super.dispose();
  }

  void _addHorario() {
    final horario = _horarioController.text.trim();
    if (horario.isEmpty) return;

    if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(horario)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Formato requerido: HH:MM (ej: 08:00)')),
      );
      return;
    }

    if (_horarios.contains(horario)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este horario ya fue agregado')),
      );
      return;
    }

    setState(() {
      _horarios.add(horario);
      _horarios.sort();
      _horarioController.clear();
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_horarios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos un horario')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<MedicamentoProvider>();
      final notifProvider = context.read<NotificationProvider>();
      final notas = _notasController.text.trim().isEmpty
          ? null
          : _notasController.text.trim();

      if (_isEditing) {
        await provider.updateMedicamento(
          id: widget.medicamento!.id,
          userId: widget.userId,
          nombre: _nombreController.text.trim(),
          dosis: _dosisController.text.trim(),
          horarios: _horarios,
          notificationProvider: notifProvider,
          notas: notas,
        );
      } else {
        await provider.addMedicamento(
          userId: widget.userId,
          nombre: _nombreController.text.trim(),
          dosis: _dosisController.text.trim(),
          horarios: _horarios,
          notificationProvider: notifProvider,
          notas: notas,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Medicamento actualizado. Notificaciones reprogramadas'
                  : 'Medicamento agregado. Notificaciones programadas',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Medicamento' : 'Nuevo Medicamento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre del medicamento',
                  hintText: 'Ej: Aspirina, Ibuprofeno',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.medication),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'El nombre es requerido' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _dosisController,
                decoration: InputDecoration(
                  labelText: 'Dosis',
                  hintText: 'Ej: 500mg, 2 comprimidos',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.balance),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'La dosis es requerida' : null,
              ),
              const SizedBox(height: 20),
              Text('Horarios de consumo', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _horarioController,
                      decoration: InputDecoration(
                        hintText: 'HH:MM',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.schedule),
                      ),
                      keyboardType: TextInputType.datetime,
                      onFieldSubmitted: (_) => _addHorario(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _addHorario,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                    child: const Text('Agregar'),
                  ),
                ],
              ),
              if (_horarios.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _horarios
                      .map((h) => Chip(
                            label: Text(h, style: const TextStyle(fontSize: 16)),
                            onDeleted: () => setState(() => _horarios.remove(h)),
                            backgroundColor: Colors.blue[100],
                            deleteIconColor: Colors.red,
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 20),
              TextFormField(
                controller: _notasController,
                decoration: InputDecoration(
                  labelText: 'Notas (opcional)',
                  hintText: 'Tomar con comida, efectos secundarios...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _isEditing ? 'Guardar Cambios' : 'Guardar Medicamento',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
