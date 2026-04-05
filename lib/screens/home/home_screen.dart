import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../providers/cita_provider.dart';
import '../../providers/notification_provider.dart';
import '../medicamentos/medicamentos_list_screen.dart';
import '../citas/citas_list_screen.dart';
import '../registro/registro_data_screen.dart';
import '../reportes/reportes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthService>().getCurrentUser()!.uid;
    context.read<CitaProvider>().loadCitas(userId);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthService>().logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Bienvenido',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(user?.email ?? '',
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),

            // Próxima cita
            Consumer<CitaProvider>(
              builder: (context, provider, _) {
                final proxima = provider.proximaCita;
                if (proxima == null) return const SizedBox.shrink();
                return Column(
                  children: [
                    Card(
                      color: Colors.blue[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    color: Colors.blue, size: 22),
                                const SizedBox(width: 8),
                                Text('Próxima Cita',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(color: Colors.blue)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              proxima.doctor,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${proxima.especialidad} • ${proxima.fechaFormato} a las ${proxima.horaFormato}',
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              proxima.estado,
                              style: TextStyle(
                                color: proxima.esHoy
                                    ? Colors.orange
                                    : Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),

            _MenuCard(
              icon: Icons.medication,
              title: 'Medicamentos',
              subtitle: 'Gestiona tus medicamentos y horarios',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const MedicamentosListScreen(),
              )),
            ),
            const SizedBox(height: 16),
            _MenuCard(
              icon: Icons.calendar_today,
              title: 'Citas Médicas',
              subtitle: 'Agenda y gestiona tus citas',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const CitasListScreen(),
              )),
            ),
            const SizedBox(height: 16),
            _MenuCard(
              icon: Icons.show_chart,
              title: 'Registro de Datos',
              subtitle: 'Glucosa, peso y más',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const RegistroDataScreen(),
              )),
            ),
            const SizedBox(height: 16),
            _MenuCard(
              icon: Icons.assessment,
              title: 'Reportes',
              subtitle: 'PDF, CSV y estadísticas',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ReportesScreen(),
              )),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<NotificationProvider>().showTestNotification(),
              icon: const Icon(Icons.notifications),
              label: const Text('Probar Notificación'),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 48, color: Colors.blue),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
