import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/registro_dato.dart';
import '../../providers/registro_provider.dart';
import '../../services/auth_service.dart';

class RegistroQuickScreen extends StatefulWidget {
  final TipoDato tipoDato;

  const RegistroQuickScreen({super.key, required this.tipoDato});

  @override
  State<RegistroQuickScreen> createState() => _RegistroQuickScreenState();
}

class _RegistroQuickScreenState extends State<RegistroQuickScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _valorController;
  late final TextEditingController _notasController;

  late DateTime _fechaSeleccionada;
  late TimeOfDay _horaSeleccionada;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _valorController = TextEditingController();
    _notasController = TextEditingController();
    _fechaSeleccionada = DateTime.now();
    _horaSeleccionada = TimeOfDay.now();
  }

  @override
  void dispose() {
    _valorController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _selectFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _fechaSeleccionada = picked);
  }

  Future<void> _selectHora() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada,
    );
    if (picked != null) setState(() => _horaSeleccionada = picked);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final valor = double.parse(_valorController.text.trim());
      final fechaCompleta = DateTime(
        _fechaSeleccionada.year,
        _fechaSeleccionada.month,
        _fechaSeleccionada.day,
        _horaSeleccionada.hour,
        _horaSeleccionada.minute,
      );
      final userId = context.read<AuthService>().getCurrentUser()!.uid;
      await context.read<RegistroProvider>().addRegistro(
            userId: userId,
            tipo: widget.tipoDato,
            valor: valor,
            notas: _notasController.text.trim().isEmpty
                ? null
                : _notasController.text.trim(),
            fecha: fechaCompleta,
          );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '${widget.tipoDato == TipoDato.glucosa ? "Glucosa" : "Peso"} registrado'),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final esGlucosa = widget.tipoDato == TipoDato.glucosa;
    return Scaffold(
      appBar: AppBar(
        title: Text(esGlucosa ? 'Registrar Glucosa' : 'Registrar Peso'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    Icon(
                      esGlucosa ? Icons.bloodtype : Icons.scale,
                      size: 64,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      esGlucosa ? 'Registrar Glucosa' : 'Registrar Peso',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _valorController,
                decoration: InputDecoration(
                  labelText: esGlucosa ? 'Glucosa (mg/dL)' : 'Peso (kg)',
                  hintText: esGlucosa ? 'Ej: 120' : 'Ej: 75.5',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon:
                      Icon(esGlucosa ? Icons.bloodtype : Icons.scale),
                  suffixText: esGlucosa ? 'mg/dL' : 'kg',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa un valor';
                  final n = double.tryParse(v);
                  if (n == null) return 'Número inválido';
                  if (n <= 0) return 'El valor debe ser mayor a 0';
                  if (esGlucosa && n > 600) return 'Valor de glucosa muy alto';
                  if (!esGlucosa && n > 300) return 'Valor de peso muy alto';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text('Fecha', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectFecha,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.blue),
                      const SizedBox(width: 12),
                      Text(_formatDate(_fechaSeleccionada),
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Hora', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectHora,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.blue),
                      const SizedBox(width: 12),
                      Text(_horaSeleccionada.format(context),
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _notasController,
                decoration: InputDecoration(
                  labelText: 'Notas (opcional)',
                  hintText: 'Cómo te sentías, medicamentos, comidas...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Registrar',
                        style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
