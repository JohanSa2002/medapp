import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cita.dart';
import '../../providers/cita_provider.dart';
import '../../providers/notification_provider.dart';
import 'cita_form_screen.dart';

class CitaDetailScreen extends StatelessWidget {
  final Cita cita;
  final String userId;

  const CitaDetailScreen({
    super.key,
    required this.cita,
    required this.userId,
  });

  Color _estadoColor() {
    if (cita.yaPaso) return Colors.grey;
    if (cita.esHoy) return Colors.orange;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Cita'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    CitaFormScreen(userId: userId, cita: cita),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Chip(
                label: Text(
                  cita.estado,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                backgroundColor: _estadoColor(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),
            _DetailRow(icon: Icons.person, title: 'Doctor', value: cita.doctor),
            _DetailRow(
                icon: Icons.medical_services,
                title: 'Especialidad',
                value: cita.especialidad),
            _DetailRow(
                icon: Icons.calendar_today,
                title: 'Fecha',
                value: cita.fechaFormato),
            _DetailRow(
                icon: Icons.access_time,
                title: 'Hora',
                value: cita.horaFormato),
            if (cita.lugar != null && cita.lugar!.isNotEmpty)
              _DetailRow(
                  icon: Icons.location_on,
                  title: 'Lugar',
                  value: cita.lugar!),
            if (cita.telefono != null && cita.telefono!.isNotEmpty)
              _DetailRow(
                  icon: Icons.phone,
                  title: 'Teléfono',
                  value: cita.telefono!),
            _DetailRow(
              icon: Icons.notifications,
              title: 'Recordatorio',
              value: cita.minutosAntes >= 1440
                  ? '${cita.minutosAntes ~/ 1440} día(s) antes'
                  : cita.minutosAntes >= 60
                      ? '${cita.minutosAntes ~/ 60} hora(s) antes'
                      : '${cita.minutosAntes} minutos antes',
            ),
            if (cita.notas != null && cita.notas!.isNotEmpty)
              _DetailRow(
                  icon: Icons.note, title: 'Notas', value: cita.notas!),
            const SizedBox(height: 32),
            if (!cita.yaPaso)
              ElevatedButton(
                onPressed: () => _showDeleteDialog(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Eliminar Cita',
                    style: TextStyle(fontSize: 16)),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
