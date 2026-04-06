import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../main.dart';
import '../../models/cita.dart';
import '../../providers/cita_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/auth_service.dart';
import 'cita_form_screen.dart';
import 'cita_detail_screen.dart';

class CitasListScreen extends StatefulWidget {
  const CitasListScreen({super.key});

  @override
  State<CitasListScreen> createState() => _CitasListScreenState();
}

class _CitasListScreenState extends State<CitasListScreen> {
  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().getCurrentUser();
    if (user != null) context.read<CitaProvider>().loadCitas(user.uid);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().getCurrentUser();
    final userId = user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: Text('Citas', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<CitaProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.citas.isEmpty) {
            return _EmptyState(onAdd: () => _navigateToForm(context, userId));
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => provider.loadCitas(userId),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 110),
              itemCount: provider.citas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final cita = provider.citas[index];
                return _CitaCard(
                  cita: cita,
                  onTap: () => _navigateToDetail(context, cita, userId),
                  onEdit: () => _navigateToForm(context, userId, cita: cita),
                  onDelete: () => _showDeleteDialog(context, cita, userId),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(context, userId),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text('Nueva cita', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _navigateToForm(BuildContext context, String userId, {Cita? cita}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CitaFormScreen(userId: userId, cita: cita),
    ));
  }

  void _navigateToDetail(BuildContext context, Cita cita, String userId) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CitaDetailScreen(cita: cita, userId: userId),
    ));
  }

  void _showDeleteDialog(BuildContext context, Cita cita, String userId) {
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
              context.read<CitaProvider>().deleteCita(
                    id: cita.id,
                    userId: userId,
                    notificationProvider: context.read<NotificationProvider>(),
                  );
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

// Empty state
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
              child: Icon(Icons.calendar_month_rounded, size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text('Sin citas', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('No tienes citas programadas. Agrega una para comenzar a recibir recordatorios.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.4)),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: Text('Agendar cita', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ],
        ),
      ),
    );
  }
}

// Cita card
class _CitaCard extends StatelessWidget {
  final Cita cita;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CitaCard({required this.cita, required this.onTap, required this.onEdit, required this.onDelete});

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
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: _badgeBg(), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.calendar_month_rounded, color: accent, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(cita.doctor, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: _badgeBg(), borderRadius: BorderRadius.circular(20)),
                            child: Text(cita.estado, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: accent)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(cita.especialidad, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Row(children: [
                        const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(cita.fechaFormato, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(width: 12),
                        const Icon(Icons.schedule_rounded, size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(cita.horaFormato, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                      ]),
                      if (cita.lugar != null && cita.lugar!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Expanded(child: Text(cita.lugar!, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                        ]),
                      ],
                      const SizedBox(height: 10),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        _ActionBtn(label: 'Editar', icon: Icons.edit_rounded, color: AppColors.primary, onTap: onEdit),
                        const SizedBox(width: 12),
                        _ActionBtn(label: 'Eliminar', icon: Icons.delete_outline_rounded, color: AppColors.error, onTap: onDelete),
                      ])
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(children: [Icon(icon, size: 14, color: color), const SizedBox(width: 6), Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: color))]),
    );
  }
}
