import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    final userId = context.read<AuthService>().getCurrentUser()!.uid;
    context.read<CitaProvider>().loadCitas(userId);
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthService>().getCurrentUser()!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Citas Médicas')),
      body: Consumer<CitaProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.citas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes citas programadas',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _navigateToForm(context, userId),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child: const Text('Agendar Cita'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.citas.length,
            itemBuilder: (context, index) {
              final cita = provider.citas[index];
              return _CitaCard(
                cita: cita,
                onTap: () => _navigateToDetail(context, cita, userId),
                onEdit: () => _navigateToForm(context, userId, cita: cita),
                onDelete: () => _showDeleteDialog(context, cita, userId),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context, userId),
        tooltip: 'Agendar cita',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToForm(BuildContext context, String userId, {Cita? cita}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CitaFormScreen(userId: userId, cita: cita),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Cita cita, String userId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CitaDetailScreen(cita: cita, userId: userId),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Cita cita, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cita'),
        content: Text('¿Eliminar cita con ${cita.doctor}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CitaProvider>().deleteCita(
                    id: cita.id,
                    userId: userId,
                    notificationProvider: context.read<NotificationProvider>(),
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cita eliminada')),
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

class _CitaCard extends StatelessWidget {
  final Cita cita;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CitaCard({
    required this.cita,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  Color _estadoColor() {
    if (cita.yaPaso) return Colors.grey;
    if (cita.esHoy) return Colors.orange;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cita.doctor,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cita.especialidad,
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      cita.estado,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: _estadoColor(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(cita.fechaFormato,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                  const SizedBox(width: 20),
                  Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(cita.horaFormato,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                ],
              ),
              if (cita.lugar != null && cita.lugar!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cita.lugar!,
                        style:
                            TextStyle(fontSize: 14, color: Colors.grey[700]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
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
      ),
    );
  }
}
