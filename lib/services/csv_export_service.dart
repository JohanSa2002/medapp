import 'package:csv/csv.dart';
import '../models/reporte.dart';

class CsvExportService {
  String exportarReporte(Reporte reporte) {
    final rows = <List<dynamic>>[];

    rows.add(['REPORTE MÉDICO – ${reporte.periodoTexto}']);
    rows.add(['Generado: ${reporte.generadoEnTexto}']);
    rows.add([]);

    // Resumen
    rows.add(['RESUMEN GENERAL']);
    rows.add(['Métrica', 'Valor']);
    rows.add(['Medicamentos Activos', reporte.medicamentosActivos]);
    rows.add([
      'Citas Completadas',
      '${reporte.citasCompletadas.length} / ${reporte.citas.length}'
    ]);
    rows.add([
      'Porcentaje Citas',
      '${reporte.porcentajeCitasCumplidas.toStringAsFixed(1)}%'
    ]);
    rows.add(['Registros Glucosa', reporte.registrosGlucosa.length]);
    rows.add(['Registros Peso', reporte.registrosPeso.length]);
    rows.add([]);

    // Glucosa
    if (reporte.registrosGlucosa.isNotEmpty) {
      rows.add(['ESTADÍSTICAS DE GLUCOSA']);
      rows.add(['Métrica', 'Valor']);
      rows.add([
        'Promedio (mg/dL)',
        reporte.promedioGlucosa?.toStringAsFixed(1) ?? 'N/A'
      ]);
      rows.add([
        'Máximo (mg/dL)',
        reporte.maxGlucosa?.toStringAsFixed(1) ?? 'N/A'
      ]);
      rows.add([
        'Mínimo (mg/dL)',
        reporte.minGlucosa?.toStringAsFixed(1) ?? 'N/A'
      ]);
      rows.add([
        'En Rango',
        '${reporte.glucosasEnRango} / ${reporte.registrosGlucosa.length}'
      ]);
      rows.add([
        'Porcentaje en Rango',
        '${reporte.porcentajeGlucosaEnRango.toStringAsFixed(1)}%'
      ]);
      rows.add([]);

      rows.add(['DETALLE GLUCOSA']);
      rows.add(['Fecha', 'Hora', 'Valor (mg/dL)', 'Categoría', 'Notas']);
      for (final r in reporte.registrosGlucosa) {
        rows.add([
          r.fechaFormato,
          r.horaFormato,
          r.valor.toStringAsFixed(1),
          r.categoriaGlucosa,
          r.notas ?? '',
        ]);
      }
      rows.add([]);
    }

    // Peso
    if (reporte.registrosPeso.isNotEmpty) {
      rows.add(['ESTADÍSTICAS DE PESO']);
      rows.add(['Métrica', 'Valor']);
      rows.add([
        'Promedio (kg)',
        reporte.promedioPeso?.toStringAsFixed(1) ?? 'N/A'
      ]);
      rows.add([
        'Máximo (kg)',
        reporte.maxPeso?.toStringAsFixed(1) ?? 'N/A'
      ]);
      rows.add([
        'Mínimo (kg)',
        reporte.minPeso?.toStringAsFixed(1) ?? 'N/A'
      ]);
      rows.add([
        'Cambio (kg)',
        reporte.cambioPeso?.toStringAsFixed(2) ?? 'N/A'
      ]);
      rows.add([]);

      rows.add(['DETALLE PESO']);
      rows.add(['Fecha', 'Hora', 'Peso (kg)', 'Notas']);
      for (final r in reporte.registrosPeso) {
        rows.add([
          r.fechaFormato,
          r.horaFormato,
          r.valor.toStringAsFixed(1),
          r.notas ?? '',
        ]);
      }
      rows.add([]);
    }

    // Medicamentos
    if (reporte.medicamentos.isNotEmpty) {
      rows.add(['MEDICAMENTOS']);
      rows.add(['Nombre', 'Dosis', 'Horarios', 'Notas']);
      for (final m in reporte.medicamentos) {
        rows.add([
          m.nombre,
          m.dosis,
          m.horarios.join(', '),
          m.notas ?? '',
        ]);
      }
      rows.add([]);
    }

    // Citas
    if (reporte.citas.isNotEmpty) {
      rows.add(['CITAS MÉDICAS']);
      rows.add(
          ['Doctor', 'Especialidad', 'Fecha', 'Hora', 'Lugar', 'Notas']);
      for (final c in reporte.citas) {
        rows.add([
          c.doctor,
          c.especialidad,
          c.fechaFormato,
          c.horaFormato,
          c.lugar ?? '',
          c.notas ?? '',
        ]);
      }
    }

    return const ListToCsvConverter().convert(rows);
  }
}
