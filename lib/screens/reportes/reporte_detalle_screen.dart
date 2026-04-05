import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:printing/printing.dart';
import '../../models/reporte.dart';
import '../../providers/reporte_provider.dart';
import '../../services/pdf_export_service.dart';
import '../../services/csv_export_service.dart';

class ReporteDetalleScreen extends StatelessWidget {
  const ReporteDetalleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Reporte'),
        actions: [
          Consumer<ReporteProvider>(
            builder: (context, provider, _) {
              if (provider.reporteActual == null) return const SizedBox();
              return PopupMenuButton<String>(
                onSelected: (val) => _handleMenu(context, val, provider.reporteActual!),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'pdf', child: Text('Descargar PDF')),
                  PopupMenuItem(value: 'csv', child: Text('Exportar CSV')),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<ReporteProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading || provider.reporteActual == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final r = provider.reporteActual!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Período
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('Período',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
                        const SizedBox(height: 8),
                        Text(r.periodoTexto,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Resumen
                _sectionTitle(context, 'RESUMEN GENERAL'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                        label: 'Medicamentos',
                        valor: '${r.medicamentosActivos}'),
                    _StatItem(
                        label: 'Citas', valor: '${r.citas.length}'),
                    _StatItem(
                        label: 'Registros',
                        valor:
                            '${r.registrosGlucosa.length + r.registrosPeso.length}'),
                  ],
                ),
                const SizedBox(height: 24),

                // Glucosa
                if (r.registrosGlucosa.isNotEmpty) ...[
                  _sectionTitle(context, 'GLUCOSA'),
                  const SizedBox(height: 12),
                  _LineChart(
                    registros: r.registrosGlucosa,
                    color: Colors.red,
                    minPad: 10,
                    maxPad: 10,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                          label: 'Promedio',
                          valor: r.promedioGlucosa?.toStringAsFixed(0) ?? '-',
                          unidad: 'mg/dL'),
                      _StatItem(
                          label: 'Máximo',
                          valor: r.maxGlucosa?.toStringAsFixed(0) ?? '-',
                          unidad: 'mg/dL'),
                      _StatItem(
                          label: 'Mínimo',
                          valor: r.minGlucosa?.toStringAsFixed(0) ?? '-',
                          unidad: 'mg/dL'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      '${r.porcentajeGlucosaEnRango.toStringAsFixed(0)}% de lecturas en rango normal',
                      style: TextStyle(
                          color: r.porcentajeGlucosaEnRango >= 70
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Peso
                if (r.registrosPeso.isNotEmpty) ...[
                  _sectionTitle(context, 'PESO'),
                  const SizedBox(height: 12),
                  _LineChart(
                    registros: r.registrosPeso,
                    color: Colors.orange,
                    minPad: 2,
                    maxPad: 2,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                          label: 'Promedio',
                          valor: r.promedioPeso?.toStringAsFixed(1) ?? '-',
                          unidad: 'kg'),
                      _StatItem(
                          label: 'Cambio',
                          valor: r.cambioPeso != null
                              ? '${r.cambioPeso! >= 0 ? '+' : ''}${r.cambioPeso!.toStringAsFixed(2)}'
                              : '-',
                          unidad: 'kg'),
                      _StatItem(
                          label: 'Registros',
                          valor: '${r.registrosPeso.length}'),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Medicamentos
                if (r.medicamentos.isNotEmpty) ...[
                  _sectionTitle(context,
                      'MEDICAMENTOS (${r.medicamentos.length})'),
                  const SizedBox(height: 12),
                  ...r.medicamentos.take(5).map((med) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(med.nombre,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(
                                'Dosis: ${med.dosis} | ${med.horarios.length} vez/día',
                                style: TextStyle(
                                    color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 24),
                ],

                // Citas
                if (r.citas.isNotEmpty) ...[
                  _sectionTitle(context, 'CITAS (${r.citas.length})'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                          label: 'Completadas',
                          valor: '${r.citasCompletadas.length}'),
                      _StatItem(
                          label: 'Pendientes',
                          valor: '${r.citasPendientes.length}'),
                      _StatItem(
                          label: 'Cumplimiento',
                          valor:
                              '${r.porcentajeCitasCumplidas.toStringAsFixed(0)}%'),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Acciones
                ElevatedButton.icon(
                  onPressed: () =>
                      _handleMenu(context, 'pdf', r),
                  icon: const Icon(Icons.download),
                  label: const Text('Descargar PDF'),
                  style: ElevatedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 16)),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () =>
                      _handleMenu(context, 'csv', r),
                  icon: const Icon(Icons.table_chart),
                  label: const Text('Exportar CSV'),
                  style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 16)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) => Text(
        text,
        style: Theme.of(context).textTheme.titleMedium,
      );

  Future<void> _handleMenu(
      BuildContext context, String action, Reporte reporte) async {
    try {
      if (action == 'pdf') {
        final bytes =
            await PdfExportService().generarPdfReporte(reporte);
        final filename =
            'reporte_medico_${reporte.generadoEn.year}${reporte.generadoEn.month.toString().padLeft(2, '0')}${reporte.generadoEn.day.toString().padLeft(2, '0')}.pdf';
        await Printing.sharePdf(bytes: bytes, filename: filename);
      } else if (action == 'csv') {
        final csv = CsvExportService().exportarReporte(reporte);
        await Clipboard.setData(ClipboardData(text: csv));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('CSV copiado al portapapeles')),
          );
        }
        return;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

class _LineChart extends StatelessWidget {
  final List registros;
  final Color color;
  final double minPad;
  final double maxPad;

  const _LineChart({
    required this.registros,
    required this.color,
    required this.minPad,
    required this.maxPad,
  });

  @override
  Widget build(BuildContext context) {
    if (registros.isEmpty) return const SizedBox.shrink();

    final spots = registros
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.valor as double))
        .toList();

    final values = registros.map((r) => r.valor as double).toList();
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: LineChart(LineChartData(
            gridData: const FlGridData(show: true),
            titlesData: const FlTitlesData(
              bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true, reservedSize: 50),
              ),
            ),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: color,
                barWidth: 3,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: color.withAlpha(26),
                ),
              ),
            ],
            minY: (minVal - minPad).clamp(0, double.infinity),
            maxY: maxVal + maxPad,
          )),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String valor;
  final String? unidad;

  const _StatItem(
      {required this.label, required this.valor, this.unidad});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(valor,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold)),
        if (unidad != null)
          Text(unidad!,
              style: TextStyle(
                  fontSize: 11, color: Colors.grey[500])),
      ],
    );
  }
}
