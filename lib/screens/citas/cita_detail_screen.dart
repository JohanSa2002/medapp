import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../main.dart';
import '../../models/cita.dart';
import '../../providers/cita_provider.dart';
import '../../providers/notification_provider.dart';
import 'cita_form_screen.dart';

class CitaDetailScreen extends StatelessWidget {
  final Cita cita;
  final String userId;

  const CitaDetailScreen({super.key, required this.cita, required this.userId});

  Color _accentColor() {
    if (cita.yaPaso) return AppColors.textHint;
    if (cita.esHoy) return AppColors.warning;
    return AppColors.primary;
  }

  Color _badgeBg() {
    if (cita.yaPaso) return const Color(0xFFF6F6F7);
    if (cita.esHoy) return AppColors.warningLight;
    return AppColors.primaryLight;
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Detalle', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            color: AppColors.textPrimary,
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CitaFormScreen(userId: userId, cita: cita))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
            child: Column(children: [
              Container(width: 64, height: 64, decoration: BoxDecoration(color: _badgeBg(), borderRadius: BorderRadius.circular(16)), child: Icon(Icons.calendar_month_rounded, color: accent, size: 34)),
              const SizedBox(height: 12),
              Text(cita.doctor, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(cita.especialidad, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: _badgeBg(), borderRadius: BorderRadius.circular(20)), child: Text(cita.estado, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: accent))),
            ]),
          ),

          const SizedBox(height: 16),

          _InfoSection(children: [
            _DetailRow(icon: Icons.calendar_today_rounded, color: AppColors.warning, title: 'Fecha', value: cita.fechaFormato),
            _DetailRow(icon: Icons.schedule_rounded, color: AppColors.primary, title: 'Hora', value: cita.horaFormato),
            _DetailRow(icon: Icons.notifications_rounded, color: AppColors.secondary, title: 'Recordatorio', value: '1 día antes'),
          ]),

          if ((cita.lugar != null && cita.lugar!.isNotEmpty) || (cita.telefono != null && cita.telefono!.isNotEmpty)) ...[
            const SizedBox(height: 12),
            _InfoSection(children: [
              if (cita.lugar != null && cita.lugar!.isNotEmpty) _DetailRow(icon: Icons.location_on_outlined, color: const Color(0xFF9B7EDE), title: 'Lugar', value: cita.lugar!),
              if (cita.telefono != null && cita.telefono!.isNotEmpty) _DetailRow(icon: Icons.phone_outlined, color: AppColors.secondary, title: 'Teléfono', value: cita.telefono!),
            ])
          ],

          if (cita.notas != null && cita.notas!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoSection(children: [_DetailRow(icon: Icons.notes_rounded, color: AppColors.textSecondary, title: 'Notas', value: cita.notas!)]),
          ],

          if (!cita.yaPaso) ...[
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => _showDeleteDialog(context),
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                label: Text('Eliminar cita', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: BorderSide(color: AppColors.error.withOpacity(0.3)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
          ],

          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Eliminar cita', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        content: Text('¿Eliminar la cita con ${cita.doctor}?', style: GoogleFonts.inter(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              context.read<CitaProvider>().deleteCita(id: cita.id, userId: userId, notificationProvider: context.read<NotificationProvider>());
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cita eliminada', style: GoogleFonts.inter())));
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final List<Widget> children;
  const _InfoSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
      child: Column(children: children.asMap().entries.map((e) => Column(children: [e.value, if (e.key < children.length - 1) Divider(height: 1, indent: 56, color: AppColors.divider)]) ).toList()),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;

  const _DetailRow({required this.icon, required this.color, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ])),
      ]),
    );
  }
}
