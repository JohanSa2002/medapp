import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
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
  final TextEditingController _horaController = TextEditingController();

  late DateTime _fechaSeleccionada;
  bool _isLoading = false;

  bool get _isEditing => widget.cita != null;

  @override
  void initState() {
    super.initState();
    _doctorController = TextEditingController(text: widget.cita?.doctor ?? '');
    _especialidadController =
        TextEditingController(text: widget.cita?.especialidad ?? '');
    _lugarController = TextEditingController(text: widget.cita?.lugar ?? '');
    _telefonoController =
        TextEditingController(text: widget.cita?.telefono ?? '');
    _notasController = TextEditingController(text: widget.cita?.notas ?? '');

    if (widget.cita != null) {
      _fechaSeleccionada = widget.cita!.fecha;
      final h = widget.cita!.fecha.hour.toString().padLeft(2, '0');
      final m = widget.cita!.fecha.minute.toString().padLeft(2, '0');
      _horaController.text = '$h:$m';
    } else {
      _fechaSeleccionada = DateTime.now().add(const Duration(days: 1));
    }
  }

  @override
  void dispose() {
    _doctorController.dispose();
    _especialidadController.dispose();
    _lugarController.dispose();
    _telefonoController.dispose();
    _notasController.dispose();
    _horaController.dispose();
    super.dispose();
  }

  // Valida formato HH:MM
  bool _isValidHora(String text) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(text.trim());
    if (match == null) return false;
    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || minute == null) return false;
    return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
  }

  DateTime _parseHoraCompleta() {
    final parts = _horaController.text.trim().split(':');
    return DateTime(
      _fechaSeleccionada.year,
      _fechaSeleccionada.month,
      _fechaSeleccionada.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
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

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isValidHora(_horaController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Ingresa una hora válida en formato HH:MM')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final fechaCompleta = _parseHoraCompleta();
      final provider = context.read<CitaProvider>();
      final notifProvider = context.read<NotificationProvider>();

      final lugar = _lugarController.text.trim().isEmpty
          ? null
          : _lugarController.text.trim();
      final telefono = _telefonoController.text.trim().isEmpty
          ? null
          : _telefonoController.text.trim();
      final notas = _notasController.text.trim().isEmpty
          ? null
          : _notasController.text.trim();

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
          notificationProvider: notifProvider,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Cita actualizada'
                : 'Cita agendada. Te recordaremos 1 día antes'),
          ),
        );
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

  String _toAmPm(String hhmm) {
    final parts = hhmm.trim().split(':');
    if (parts.length != 2) return '';
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return '';
    final period = hour >= 12 ? 'PM' : 'AM';
    int h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$h:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar cita' : 'Nueva cita'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Label('Doctor'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _doctorController,
                decoration: const InputDecoration(
                  hintText: 'Ej: Dr. Juan Pérez',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (v) => (v == null || v.isEmpty)
                    ? 'El nombre del doctor es requerido'
                    : null,
              ),
              const SizedBox(height: 16),
              const _Label('Especialidad'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _especialidadController,
                decoration: const InputDecoration(
                  hintText: 'Ej: Cardiología, Pediatría',
                  prefixIcon: Icon(Icons.medical_services_outlined),
                ),
                validator: (v) => (v == null || v.isEmpty)
                    ? 'La especialidad es requerida'
                    : null,
              ),
              const SizedBox(height: 16),
              const _Label('Fecha'),
              const SizedBox(height: 6),
              InkWell(
                onTap: _selectFecha,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.divider),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _formatDate(_fechaSeleccionada),
                        style: GoogleFonts.inter(
                            fontSize: 15, color: AppColors.textPrimary),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const _Label('Hora'),
              const SizedBox(height: 4),
              Text(
                'Ingresa la hora en 24h: HH:MM (ej: 10:00, 15:30). Se mostrara en AM/PM.',
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _horaController,
                readOnly: true,
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) {
                    final h = picked.hour.toString().padLeft(2, '0');
                    final m = picked.minute.toString().padLeft(2, '0');
                    setState(() {
                      _horaController.text = '$h:$m';
                    });
                  }
                },
                decoration: const InputDecoration(
                  hintText: 'Toca para seleccionar hora',
                  prefixIcon: Icon(Icons.schedule_rounded),
                ),
              ),
              if (_isValidHora(_horaController.text)) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded,
                        size: 14, color: AppColors.secondary),
                    const SizedBox(width: 6),
                    Text(
                      _toAmPm(_horaController.text),
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              const _Label('Lugar (opcional)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _lugarController,
                decoration: const InputDecoration(
                  hintText: 'Clínica, hospital, consultorio',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 16),
              const _Label('Teléfono (opcional)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  hintText: 'Ej: +1 234 567 8900',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              const _Label('Notas (opcional)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notasController,
                decoration: const InputDecoration(
                  hintText: 'Síntomas, preguntas para el doctor...',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(_isEditing ? 'Guardar cambios' : 'Agendar cita'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}
