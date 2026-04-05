import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reporte_provider.dart';
import '../../services/auth_service.dart';
import 'reporte_detalle_screen.dart';

class ReportesScreen extends StatelessWidget {
  const ReportesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthService>().getCurrentUser()!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Generar Reportes',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            _ReporteButton(
              titulo: 'Reporte Semanal',
              subtitulo: 'Últimos 7 días',
              icono: Icons.date_range,
              color: Colors.blue,
              onTap: () async {
                await context
                    .read<ReporteProvider>()
                    .generarReporteSemanal(userId);
                if (context.mounted) _navDetalle(context);
              },
            ),
            const SizedBox(height: 12),
            _ReporteButton(
              titulo: 'Reporte Mensual',
              subtitulo: 'Últimos 30 días',
              icono: Icons.calendar_today,
              color: Colors.green,
              onTap: () async {
                await context
                    .read<ReporteProvider>()
                    .generarReporteMensual(userId);
                if (context.mounted) _navDetalle(context);
              },
            ),
            const SizedBox(height: 12),
            _ReporteButton(
              titulo: 'Reporte Trimestral',
              subtitulo: 'Últimos 90 días',
              icono: Icons.event_note,
              color: Colors.orange,
              onTap: () async {
                await context
                    .read<ReporteProvider>()
                    .generarReporteTrimestral(userId);
                if (context.mounted) _navDetalle(context);
              },
            ),
            const SizedBox(height: 12),
            _ReporteButton(
              titulo: 'Reporte Anual',
              subtitulo: 'Últimos 365 días',
              icono: Icons.assessment,
              color: Colors.red,
              onTap: () async {
                await context
                    .read<ReporteProvider>()
                    .generarReporteAnual(userId);
                if (context.mounted) _navDetalle(context);
              },
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Información',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    const _InfoItem(
                      titulo: 'Descargable',
                      contenido: 'Genera PDF para compartir con tu médico',
                    ),
                    const SizedBox(height: 8),
                    const _InfoItem(
                      titulo: 'Exportable',
                      contenido: 'Exporta datos en formato CSV',
                    ),
                    const SizedBox(height: 8),
                    const _InfoItem(
                      titulo: 'Completo',
                      contenido:
                          'Incluye medicamentos, citas, glucosa y peso',
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

  void _navDetalle(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const ReporteDetalleScreen(),
    ));
  }
}

class _ReporteButton extends StatefulWidget {
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final Color color;
  final Future<void> Function() onTap;

  const _ReporteButton({
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ReporteButton> createState() => _ReporteButtonState();
}

class _ReporteButtonState extends State<_ReporteButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: _loading ? null : _handle,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
                color: widget.color.withAlpha(77)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(widget.icono, size: 48, color: widget.color),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.titulo,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(widget.subtitulo,
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
              _loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child:
                          CircularProgressIndicator(strokeWidth: 2))
                  : Icon(Icons.arrow_forward_ios,
                      color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handle() async {
    setState(() => _loading = true);
    try {
      await widget.onTap();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
        const Icon(Icons.check_circle, size: 20, color: Colors.green),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo,
                  style:
                      const TextStyle(fontWeight: FontWeight.w500)),
              Text(contenido,
                  style: TextStyle(
                      color: Colors.grey[600], fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}
