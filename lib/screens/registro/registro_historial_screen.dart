import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/registro_dato.dart';
import '../../providers/registro_provider.dart';
import '../../services/auth_service.dart';
import 'registro_quick_screen.dart';

class RegistroHistorialScreen extends StatefulWidget {
  final TipoDato tipoDato;

  const RegistroHistorialScreen({super.key, required this.tipoDato});

  @override
  State<RegistroHistorialScreen> createState() =>
      _RegistroHistorialScreenState();
}

class _RegistroHistorialScreenState extends State<RegistroHistorialScreen> {
  int _diasSeleccionados = 7;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthService>().getCurrentUser()!.uid;
      context.read<RegistroProvider>().loadRegistros(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthService>().getCurrentUser()!.uid;
    final titulo =
        widget.tipoDato == TipoDato.glucosa ? 'Glucosa' : 'Peso';

    return Scaffold(
      appBar: AppBar(title: Text('Historial de $titulo')),
      body: Consumer<RegistroProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final registros = widget.tipoDato == TipoDato.glucosa
              ? provider.registrosGlucosa
              : provider.registrosPeso;

          if (registros.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.tipoDato == TipoDato.glucosa
                        ? Icons.bloodtype
                        : Icons.scale,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay registros de $titulo',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _navigateToQuick(context),
                    child: const Text('Registrar ahora'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _RangeButton(
                      label: '7 días',
                      isSelected: _diasSeleccionados == 7,
                      onTap: () =>
                          setState(() => _diasSeleccionados = 7),
                    ),
                    const SizedBox(width: 8),
                    _RangeButton(
                      label: '14 días',
                      isSelected: _diasSeleccionados == 14,
                      onTap: () =>
                          setState(() => _diasSeleccionados = 14),
                    ),
                    const SizedBox(width: 8),
                    _RangeButton(
                      label: '30 días',
                      isSelected: _diasSeleccionados == 30,
                      onTap: () =>
                          setState(() => _diasSeleccionados = 30),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildGrafica(registros),
                const SizedBox(height: 24),
                _buildEstadisticas(provider),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _navigateToQuick(context),
                  icon: const Icon(Icons.add),
                  label: Text('Registrar $titulo'),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
                const SizedBox(height: 24),
                Text('Últimos registros',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                ..._buildHistorial(registros, userId, context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrafica(List<RegistroDato> registros) {
    final filtrados = registros
        .where((r) => r.fecha.isAfter(
            DateTime.now().subtract(Duration(days: _diasSeleccionados))))
        .toList();

    if (filtrados.isEmpty) {
      return Card(
        child: SizedBox(
          height: 200,
          child: Center(
            child: Text('Sin datos en los últimos $_diasSeleccionados días',
                style: TextStyle(color: Colors.grey[600])),
          ),
        ),
      );
    }

    final spots = filtrados
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.valor))
        .toList();

    final minVal =
        filtrados.map((r) => r.valor).reduce((a, b) => a < b ? a : b);
    final maxVal =
        filtrados.map((r) => r.valor).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true),
              titlesData: const FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles:
                      SideTitles(showTitles: true, reservedSize: 50),
                ),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withAlpha(26),
                  ),
                ),
              ],
              minY: (minVal - 10).clamp(0, double.infinity),
              maxY: maxVal + 10,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEstadisticas(RegistroProvider provider) {
    final esGlucosa = widget.tipoDato == TipoDato.glucosa;
    final unidad = esGlucosa ? 'mg/dL' : 'kg';
    return Row(
      children: [
        _StatCard(
          label: 'Promedio',
          valor: esGlucosa ? provider.promedioGlucosa : provider.promedioPeso,
          unidad: unidad,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Máximo',
          valor: esGlucosa ? provider.maxGlucosa : provider.maxPeso,
          unidad: unidad,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Mínimo',
          valor: esGlucosa ? provider.minGlucosa : provider.minPeso,
          unidad: unidad,
        ),
      ],
    );
  }

  List<Widget> _buildHistorial(
    List<RegistroDato> registros,
    String userId,
    BuildContext context,
    RegistroProvider provider,
  ) {
    final filtrados = registros
        .where((r) => r.fecha.isAfter(
            DateTime.now().subtract(const Duration(days: 30))))
        .take(10)
        .toList();

    return filtrados.map((registro) {
      return GestureDetector(
        onLongPress: () =>
            _showDeleteDialog(context, registro, userId, provider),
        child: Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${registro.valor} ${registro.unidadFormato}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (widget.tipoDato == TipoDato.glucosa)
                      Text(
                        registro.categoriaGlucosa,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[600]),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(registro.fechaFormato,
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey[700])),
                    Text(registro.horaFormato,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  void _navigateToQuick(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) =>
          RegistroQuickScreen(tipoDato: widget.tipoDato),
    ));
  }

  void _showDeleteDialog(
    BuildContext context,
    RegistroDato registro,
    String userId,
    RegistroProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar registro'),
        content: Text(
            '¿Eliminar el registro de ${registro.valor} ${registro.unidadFormato}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteRegistro(id: registro.id, userId: userId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Registro eliminado')),
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

class _RangeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RangeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double? valor;
  final String unidad;

  const _StatCard({
    required this.label,
    required this.valor,
    required this.unidad,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(
                valor != null ? valor!.toStringAsFixed(1) : '-',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(unidad,
                  style: TextStyle(fontSize: 10, color: Colors.grey[500])),
            ],
          ),
        ),
      ),
    );
  }
}
