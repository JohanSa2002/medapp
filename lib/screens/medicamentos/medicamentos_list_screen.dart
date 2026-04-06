import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
import '../../models/medicamento.dart';
import '../../providers/medicamento_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/auth_service.dart';
import 'medicamento_form_screen.dart';

class MedicamentosListScreen extends StatefulWidget {
  const MedicamentosListScreen({super.key});

  @override
  State<MedicamentosListScreen> createState() => _MedicamentosListScreenState();
}

class _MedicamentosListScreenState extends State<MedicamentosListScreen> {
  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthService>().getCurrentUser()!.uid;
    context.read<MedicamentoProvider>().loadMedicamentos(userId);
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthService>().getCurrentUser()!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicamentos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(context, userId),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Agregar'),
      ),
      body: Consumer<MedicamentoProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.medicamentos.isEmpty) {
            return _EmptyState(onAdd: () => _navigateToForm(context, userId));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            itemCount: provider.medicamentos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final med = provider.medicamentos[index];
              return _MedicamentoCard(
                medicamento: med,
                onEdit: () => _navigateToForm(context, userId, medicamento: med),
                onDelete: () => _showDeleteDialog(context, med, userId),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToForm(BuildContext context, String userId, {Medicamento? medicamento}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MedicamentoFormScreen(userId: userId, medicamento: medicamento),
    ));
  }

  void _showDeleteDialog(BuildContext context, Medicamento medicamento, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Eliminar medicamento',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        content: Text(
          '¿Deseas eliminar "${medicamento.nombre}"?\nSe cancelarán todas sus notificaciones.',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final notifProvider = context.read<NotificationProvider>();
              context.read<MedicamentoProvider>().deleteMedicamento(
                    id: medicamento.id,
                    userId: userId,
                    notificationProvider: notifProvider,
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Medicamento eliminado')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.medication_rounded, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              'Sin medicamentos',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega tus medicamentos para recibir recordatorios puntuales',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Agregar medicamento'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicamentoCard extends StatelessWidget {
  final Medicamento medicamento;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MedicamentoCard({
    required this.medicamento,
    required this.onEdit,
    required this.onDelete,
  });

  String _toAmPm(String hhmm) {
    final parts = hhmm.split(':');
    int hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) hour = 12;
    else if (hour > 12) hour -= 12;
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Accent bar + contenido
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Barra de color izquierda
                Container(
                  width: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                // Contenido
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.medication_rounded,
                                  color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                medicamento.nombre,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _InfoRow(
                          icon: Icons.scale_rounded,
                          text: 'Dosis: ${medicamento.dosis}',
                        ),
                        if (medicamento.notas != null && medicamento.notas!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          _InfoRow(
                            icon: Icons.notes_rounded,
                            text: medicamento.notas!,
                          ),
                        ],
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: medicamento.horarios
                              .map((h) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.access_time_rounded,
                                            size: 12, color: AppColors.primary),
                                        const SizedBox(width: 4),
                                        Text(
                                          _toAmPm(h),
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Acciones
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Editar'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                Container(width: 1, height: 36, color: AppColors.divider),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: const Text('Eliminar'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
