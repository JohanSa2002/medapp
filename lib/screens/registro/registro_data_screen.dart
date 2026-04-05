import 'package:flutter/material.dart';
import '../../models/registro_dato.dart';
import 'registro_quick_screen.dart';
import 'registro_historial_screen.dart';

class RegistroDataScreen extends StatelessWidget {
  const RegistroDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Datos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DataCard(
              icon: Icons.bloodtype,
              titulo: 'Glucosa',
              subtitulo: 'Monitorea tus niveles de glucosa en sangre',
              color: Colors.red,
              onRegistrar: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    const RegistroQuickScreen(tipoDato: TipoDato.glucosa),
              )),
              onHistorial: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    const RegistroHistorialScreen(tipoDato: TipoDato.glucosa),
              )),
            ),
            const SizedBox(height: 20),
            _DataCard(
              icon: Icons.scale,
              titulo: 'Peso',
              subtitulo: 'Registra tu peso para seguimiento',
              color: Colors.orange,
              onRegistrar: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    const RegistroQuickScreen(tipoDato: TipoDato.peso),
              )),
              onHistorial: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    const RegistroHistorialScreen(tipoDato: TipoDato.peso),
              )),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Información útil',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    const _InfoItem(
                      titulo: 'Glucosa normal (en ayunas)',
                      contenido: '70 - 100 mg/dL',
                    ),
                    const SizedBox(height: 8),
                    const _InfoItem(
                      titulo: 'Prediabetes',
                      contenido: '101 - 125 mg/dL',
                    ),
                    const SizedBox(height: 8),
                    const _InfoItem(
                      titulo: 'Diabetes',
                      contenido: '≥ 126 mg/dL',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final Color color;
  final VoidCallback onRegistrar;
  final VoidCallback onHistorial;

  const _DataCard({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.color,
    required this.onRegistrar,
    required this.onHistorial,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 48, color: color),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(subtitulo,
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onRegistrar,
                    icon: const Icon(Icons.add),
                    label: const Text('Registrar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onHistorial,
                    icon: const Icon(Icons.history),
                    label: const Text('Historial'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String titulo;
  final String contenido;

  const _InfoItem({required this.titulo, required this.contenido});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(contenido,
                  style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }
}
