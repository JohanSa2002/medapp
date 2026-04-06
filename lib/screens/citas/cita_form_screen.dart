import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cita.dart';
import '../../providers/cita_provider.dart';
import '../../providers/notification_provider.dart';

class CitaFormScreen extends StatefulWidget {
  final String userId;
  final Cita? cita;

  const CitaFormScreen({super.key, required this.userId, this.cita});

  @override
  State<CitaFormScreen> createState() => _CitaFormScreenState();
}

class _CitaFormScreenState extends State<CitaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _doctorController;
  late final TextEditingController _especialidadController;
  late final TextEditingController _lugarController;
  late final TextEditingController _telefonoController;
  late final TextEditingController _notasController;

  late DateTime _fechaSeleccionada;
  late TimeOfDay _horaSeleccionada;
  int _minutosAntes = 1440;
  bool _isLoading = false;

  bool get _isEditing => widget.cita != null;

  @override
  void initState() {
    super.initState();
    _doctorController =
        TextEditingController(text: widget.cita?.doctor ?? '');
    _especialidadController =
        TextEditingController(text: widget.cita?.especialidad ?? '');
    _lugarController =
        TextEditingController(text: widget.cita?.lugar ?? '');
    _telefonoController =
        TextEditingController(text: widget.cita?.telefono ?? '');
    _notasController =
        TextEditingController(text: widget.cita?.notas ?? '');

    if (widget.cita != null) {
      _fechaSeleccionada = widget.cita!.fecha;
      _horaSeleccionada = TimeOfDay.fromDateTime(widget.cita!.fecha);
      _minutosAntes = widget.cita!.minutosAntes;
    } else {
      _fechaSeleccionada = DateTime.now().add(const Duration(days: 1));
      _horaSeleccionada = const TimeOfDay(hour: 10, minute: 0);
    }
  }

  @override
  void dispose() {
    _doctorController.dispose();
    _especialidadController.dispose();
    _lugarController.dispose();
    _telefonoController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _selectFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _fechaSeleccionada = picked);
  }

  Future<void> _selectHora() async {
    final picked =
        await showTimePicker(context: context, initialTime: _horaSeleccionada);
    if (picked != null) setState(() => _horaSeleccionada = picked);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final fechaCompleta = DateTime(
        _fechaSeleccionada.year,
        _fechaSeleccionada.month,
        _fechaSeleccionada.day,
        _horaSeleccionada.hour,
        _horaSeleccionada.minute,
      );

      final provider = context.read<CitaProvider>();
      final notifProvider = context.read<NotificationProvider>();

      String? lugar =
          _lugarController.text.trim().isEmpty ? null : _lugarController.text.trim();
      String? telefono =
          _telefonoController.text.trim().isEmpty ? null : _telefonoController.text.trim();
      String? notas =
          _notasController.text.trim().isEmpty ? null : _notasController.text.trim();

      if (_isEditing) {
        await provider.updateCita(
          id: widget.cita!.id,
          userId: widget.userId,
          doctor: _doctorController.text.trim(),
          especialidad: _especialidadController.text.trim(),
          fecha: fechaCompleta,
          lugar: lugar,
          telefono: telefono,
          notas: notas,
          minutosAntes: _minutosAntes,
          notificationProvider: notifProvider,
        );
      } else {
        await provider.addCita(
          userId: widget.userId,
          doctor: _doctorController.text.trim(),
          especialidad: _especialidadController.text.trim(),
          fecha: fechaCompleta,
          lugar: lugar,
          telefono: telefono,
          notas: notas,
          minutosAntes: _minutosAntes,
          notificationProvider: notifProvider,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Cita actualizada. Recordatorio reprogramado'
                : 'Cita agendada. Recordatorio programado'),
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

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Cita' : 'Nueva Cita'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _doctorController,
                decoration: InputDecoration(
                  labelText: 'Nombre del doctor',
                  hintText: 'Ej: Dr. Juan Pérez',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'El nombre del doctor es requerido' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _especialidadController,
                decoration: InputDecoration(
                  labelText: 'Especialidad',
                  hintText: 'Ej: Cardiología, Pediatría',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.medical_services),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'La especialidad es requerida' : null,
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
                controller: _lugarController,
                decoration: InputDecoration(
                  labelText: 'Lugar (opcional)',
                  hintText: 'Clínica, hospital, consultorio',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _telefonoController,
                decoration: InputDecoration(
                  labelText: 'Teléfono (opcional)',
                  hintText: 'Ej: +1 234 567 8900',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              Text('Recordatorio antes de la cita',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 30, label: Text('30 min')),
                  ButtonSegment(value: 60, label: Text('1 hora')),
                  ButtonSegment(value: 120, label: Text('2 horas')),
                  ButtonSegment(value: 1440, label: Text('1 día')),
                ],
                selected: {_minutosAntes},
                onSelectionChanged: (s) =>
                    setState(() => _minutosAntes = s.first),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _notasController,
                decoration: InputDecoration(
                  labelText: 'Notas (opcional)',
                  hintText: 'Síntomas, preguntas para el doctor...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
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
                    : Text(
                        _isEditing ? 'Guardar Cambios' : 'Agendar Cita',
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
