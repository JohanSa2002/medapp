import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
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

  List<String> _horarios = []; // siempre en formato HH:MM internamente
  bool _isLoading = false;

  // Estado del campo de horario
  _HorarioStatus _horarioStatus = _HorarioStatus.empty;

  bool get _isEditing => widget.medicamento != null;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.medicamento?.nombre ?? '');
    _dosisController = TextEditingController(text: widget.medicamento?.dosis ?? '');
    _notasController = TextEditingController(text: widget.medicamento?.notas ?? '');
    _horarios = List<String>.from(widget.medicamento?.horarios ?? []);
    _horarioController.addListener(_onHorarioChanged);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _dosisController.dispose();
    _notasController.dispose();
    _horarioController.removeListener(_onHorarioChanged);
    _horarioController.dispose();
    super.dispose();
  }

  void _onHorarioChanged() {
    final text = _horarioController.text.trim();
    if (text.isEmpty) {
      setState(() => _horarioStatus = _HorarioStatus.empty);
      return;
    }
    setState(() {
      _horarioStatus = _isValidHorario(text)
          ? _HorarioStatus.valid
          : _HorarioStatus.invalid;
    });
  }

  // Valida formato h:mm AM/PM (ej: "8:30 AM", "2:30 PM")
  bool _isValidHorario(String text) {
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM|am|pm)$',
    ).firstMatch(text.trim());
    if (match == null) return false;
    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || minute == null) return false;
    return hour >= 1 && hour <= 12 && minute >= 0 && minute <= 59;
  }

  // Convierte "h:mm AM/PM" → "HH:MM" para almacenamiento interno
  String _normalize(String text) {
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM|am|pm)$',
    ).firstMatch(text.trim())!;
    int hour = int.parse(match.group(1)!);
    final minute = match.group(2)!;
    final period = match.group(3)!.toUpperCase();
    if (period == 'AM' && hour == 12) hour = 0;
    if (period == 'PM' && hour != 12) hour += 12;
    return '${hour.toString().padLeft(2, '0')}:$minute';
  }

  // Convierte HH:MM a h:mm AM/PM para mostrar
  String _toAmPm(String hhmm) {
    final parts = hhmm.split(':');
    int hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) hour = 12;
    else if (hour > 12) hour -= 12;
    return '$hour:$minute $period';
  }

  void _addHorario() {
    final text = _horarioController.text.trim();
    if (text.isEmpty) return;
    if (!_isValidHorario(text)) return;

    final normalized = _normalize(text);
    if (_horarios.contains(normalized)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este horario ya fue agregado')),
      );
      return;
    }

    setState(() {
      _horarios.add(normalized);
      _horarios.sort();
      _horarioController.clear();
      _horarioStatus = _HorarioStatus.empty;
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
                  ? 'Medicamento actualizado'
                  : 'Medicamento guardado',
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
        title: Text(_isEditing ? 'Editar medicamento' : 'Nuevo medicamento'),
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
              _Label('Nombre del medicamento'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  hintText: 'Ej: Aspirina, Ibuprofeno',
                  prefixIcon: Icon(Icons.medication_rounded),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'El nombre es requerido' : null,
              ),
              const SizedBox(height: 16),
              _Label('Dosis'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _dosisController,
                decoration: const InputDecoration(
                  hintText: 'Ej: 500mg, 2 comprimidos',
                  prefixIcon: Icon(Icons.scale_rounded),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'La dosis es requerida' : null,
              ),
              const SizedBox(height: 20),

              // ─── Horarios ────────────────────────────────────────────────
              _Label('Horarios de consumo'),
              const SizedBox(height: 4),
              Text(
                'Formato: h:mm AM/PM  (ej: 8:00 AM, 2:30 PM, 9:00 PM)',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _horarioController,
                      decoration: InputDecoration(
                        hintText: 'ej: 8:00 AM',
                        prefixIcon: const Icon(Icons.schedule_rounded),
                        // ─── Indicador check / X ──────────────────────────
                        suffixIcon: _buildStatusIcon(),
                      ),
                      keyboardType: TextInputType.datetime,
                      onFieldSubmitted: (_) => _addHorario(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _horarioStatus == _HorarioStatus.valid
                          ? _addHorario
                          : null,
                      child: const Text('Agregar'),
                    ),
                  ),
                ],
              ),

              // ─── Chips de horarios agregados ──────────────────────────
              if (_horarios.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _horarios
                      .map((h) => _HorarioChip(
                            label: _toAmPm(h),
                            onDelete: () =>
                                setState(() => _horarios.remove(h)),
                          ))
                      .toList(),
                ),
              ] else ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Agrega al menos un horario',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
              _Label('Notas (opcional)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notasController,
                decoration: const InputDecoration(
                  hintText: 'Tomar con comida, efectos secundarios...',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_isEditing
                          ? 'Guardar cambios'
                          : 'Guardar medicamento'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildStatusIcon() {
    switch (_horarioStatus) {
      case _HorarioStatus.valid:
        return const Icon(Icons.check_circle_rounded,
            color: Color(0xFF52C4A0), size: 22);
      case _HorarioStatus.invalid:
        return const Icon(Icons.cancel_rounded,
            color: AppColors.error, size: 22);
      case _HorarioStatus.empty:
        return null;
    }
  }
}

enum _HorarioStatus { empty, valid, invalid }

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _HorarioChip extends StatelessWidget {
  final String label;
  final VoidCallback onDelete;

  const _HorarioChip({required this.label, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time_rounded,
              size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close_rounded,
                size: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
