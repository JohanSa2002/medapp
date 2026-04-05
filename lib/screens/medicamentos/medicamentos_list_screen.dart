import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      appBar: AppBar(title: const Text('Mis Medicamentos')),
      body: Consumer<MedicamentoProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.medicamentos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medication, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes medicamentos registrados',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _navigateToForm(context, userId),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: const Text('Agregar Medicamento'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.medicamentos.length,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context, userId),
        tooltip: 'Agregar medicamento',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToForm(BuildContext context, String userId,
      {Medicamento? medicamento}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MedicamentoFormScreen(
          userId: userId,
          medicamento: medicamento,
        ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, Medicamento medicamento, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar medicamento'),
        content: Text(
          '¿Eliminar "${medicamento.nombre}"?\nSe cancelarán todas sus notificaciones.',
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
                const SnackBar(
                  content: Text('Medicamento eliminado. Notificaciones canceladas'),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              medicamento.nombre,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Dosis: ${medicamento.dosis}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: medicamento.horarios
                  .map((h) => Chip(
                        label: Text(h, style: const TextStyle(fontSize: 14)),
                        backgroundColor: Colors.blue[100],
                      ))
                  .toList(),
            ),
            if (medicamento.notas != null && medicamento.notas!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Notas: ${medicamento.notas}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: onEdit, child: const Text('Editar')),
                TextButton(
                  onPressed: onDelete,
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Eliminar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
