import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
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
  final TextEditingController _horaController = TextEditingController();

  late DateTime _fechaSeleccionada;
  _HoraStatus _horaStatus = _HoraStatus.empty;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _valorController = TextEditingController();
    _notasController = TextEditingController();
    _fechaSeleccionada = DateTime.now();

    // Pre-llenar con la hora actual en formato AM/PM
    final now = TimeOfDay.now();
    _horaController.text = _timeOfDayToAmPm(now);
    _horaStatus = _HoraStatus.valid;

    _horaController.addListener(_onHoraChanged);
  }

  @override
  void dispose() {
    _valorController.dispose();
    _notasController.dispose();
    _horaController.removeListener(_onHoraChanged);
    _horaController.dispose();
    super.dispose();
  }

  void _onHoraChanged() {
    final text = _horaController.text.trim();
    if (text.isEmpty) {
      setState(() => _horaStatus = _HoraStatus.empty);
      return;
    }
    setState(() {
      _horaStatus =
          _isValidHora(text) ? _HoraStatus.valid : _HoraStatus.invalid;
    });
  }

  bool _isValidHora(String text) {
    final match =
        RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM|am|pm)$').firstMatch(text.trim());
    if (match == null) return false;
    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || minute == null) return false;
    return hour >= 1 && hour <= 12 && minute >= 0 && minute <= 59;
  }

  // "h:mm AM/PM" → DateTime con la fecha seleccionada
  DateTime _parseHora() {
    final text = _horaController.text.trim();
    final match =
        RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM|am|pm)$').firstMatch(text)!;
    int hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final period = match.group(3)!.toUpperCase();
    if (period == 'AM' && hour == 12) hour = 0;
    if (period == 'PM' && hour != 12) hour += 12;
    return DateTime(
      _fechaSeleccionada.year,
      _fechaSeleccionada.month,
      _fechaSeleccionada.day,
      hour,
      minute,
    );
  }

  String _timeOfDayToAmPm(TimeOfDay t) {
    int hour = t.hour;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }
    return '$hour:$minute $period';
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

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isValidHora(_horaController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa una hora válida (ej: 8:30 AM)')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final valor = double.parse(_valorController.text.trim());
      final fechaCompleta = _parseHora();
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
            '${widget.tipoDato == TipoDato.glucosa ? "Glucosa" : "Peso"} registrado',
          ),
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
              // Ícono y título
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: esGlucosa
                            ? AppColors.primaryLight
                            : AppColors.secondaryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        esGlucosa ? Icons.bloodtype_rounded : Icons.scale_rounded,
                        size: 32,
                        color: esGlucosa ? AppColors.primary : AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      esGlucosa ? 'Registrar Glucosa' : 'Registrar Peso',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Valor
              _Label(esGlucosa ? 'Glucosa (mg/dL)' : 'Peso (kg)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _valorController,
                decoration: InputDecoration(
                  hintText: esGlucosa ? 'Ej: 120' : 'Ej: 75.5',
                  prefixIcon: Icon(
                    esGlucosa ? Icons.bloodtype_rounded : Icons.scale_rounded,
                  ),
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

              // Fecha
              const _Label('Fecha'),
              const SizedBox(height: 6),
              InkWell(
                onTap: _selectFecha,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
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
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Hora — mismo patrón que medicamentos
              const _Label('Hora'),
              const SizedBox(height: 4),
              Text(
                'Formato: h:mm AM/PM  (ej: 8:30 AM, 2:00 PM)',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _horaController,
                decoration: InputDecoration(
                  hintText: 'ej: 8:30 AM',
                  prefixIcon: const Icon(Icons.schedule_rounded),
                  suffixIcon: _buildStatusIcon(),
                ),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 20),

              // Notas
              const _Label('Notas (opcional)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notasController,
                decoration: const InputDecoration(
                  hintText: 'Cómo te sentías, medicamentos, comidas...',
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
                      : const Text('Registrar'),
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
    switch (_horaStatus) {
      case _HoraStatus.valid:
        return const Icon(Icons.check_circle_rounded,
            color: Color(0xFF52C4A0), size: 22);
      case _HoraStatus.invalid:
        return const Icon(Icons.cancel_rounded,
            color: AppColors.error, size: 22);
      case _HoraStatus.empty:
        return null;
    }
  }
}

enum _HoraStatus { empty, valid, invalid }

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
