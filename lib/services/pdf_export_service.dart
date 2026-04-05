import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/reporte.dart';

class PdfExportService {
  Future<Uint8List> generarPdfReporte(Reporte reporte) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Encabezado
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  'REPORTE MÉDICO',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                pw.Text('Período: ${reporte.periodoTexto}',
                    style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Generado: ${reporte.generadoEnTexto}',
                    style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Resumen
          _sectionTitle('RESUMEN GENERAL'),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              _headerRow(['Métrica', 'Valor']),
              _dataRow([
                'Medicamentos Activos',
                '${reporte.medicamentosActivos}'
              ]),
              _dataRow([
                'Citas Completadas',
                '${reporte.citasCompletadas.length} / ${reporte.citas.length} (${reporte.porcentajeCitasCumplidas.toStringAsFixed(1)}%)'
              ]),
              _dataRow([
                'Registros de Glucosa',
                '${reporte.registrosGlucosa.length}'
              ]),
              _dataRow(
                  ['Registros de Peso', '${reporte.registrosPeso.length}']),
            ],
          ),
          pw.SizedBox(height: 24),

          // Glucosa
          if (reporte.registrosGlucosa.isNotEmpty) ...[
            _sectionTitle('ESTADÍSTICAS DE GLUCOSA'),
            pw.SizedBox(height: 12),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                _headerRow(['Métrica', 'Valor']),
                _dataRow([
                  'Promedio',
                  '${reporte.promedioGlucosa?.toStringAsFixed(1) ?? 'N/A'} mg/dL'
                ]),
                _dataRow([
                  'Máximo',
                  '${reporte.maxGlucosa?.toStringAsFixed(1) ?? 'N/A'} mg/dL'
                ]),
                _dataRow([
                  'Mínimo',
                  '${reporte.minGlucosa?.toStringAsFixed(1) ?? 'N/A'} mg/dL'
                ]),
                _dataRow([
                  'En Rango Normal',
                  '${reporte.glucosasEnRango} / ${reporte.registrosGlucosa.length} (${reporte.porcentajeGlucosaEnRango.toStringAsFixed(1)}%)'
                ]),
              ],
            ),
            pw.SizedBox(height: 24),
          ],

          // Peso
          if (reporte.registrosPeso.isNotEmpty) ...[
            _sectionTitle('ESTADÍSTICAS DE PESO'),
            pw.SizedBox(height: 12),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                _headerRow(['Métrica', 'Valor']),
                _dataRow([
                  'Promedio',
                  '${reporte.promedioPeso?.toStringAsFixed(1) ?? 'N/A'} kg'
                ]),
                _dataRow([
                  'Máximo',
                  '${reporte.maxPeso?.toStringAsFixed(1) ?? 'N/A'} kg'
                ]),
                _dataRow([
                  'Mínimo',
                  '${reporte.minPeso?.toStringAsFixed(1) ?? 'N/A'} kg'
                ]),
                _dataRow([
                  'Cambio',
                  '${reporte.cambioPeso != null ? (reporte.cambioPeso! >= 0 ? '+' : '') + reporte.cambioPeso!.toStringAsFixed(2) : 'N/A'} kg'
                ]),
              ],
            ),
            pw.SizedBox(height: 24),
          ],

          // Medicamentos
          if (reporte.medicamentos.isNotEmpty) ...[
            _sectionTitle('MEDICAMENTOS ACTIVOS'),
            pw.SizedBox(height: 12),
            ...reporte.medicamentos.map((med) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(med.nombre,
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold)),
                      pw.Text('Dosis: ${med.dosis}'),
                      pw.Text('Horarios: ${med.horarios.join(", ")}'),
                      if (med.notas != null && med.notas!.isNotEmpty)
                        pw.Text('Notas: ${med.notas}'),
                    ],
                  ),
                )),
            pw.SizedBox(height: 24),
          ],

          // Citas
          if (reporte.citas.isNotEmpty) ...[
            _sectionTitle('CITAS MÉDICAS'),
            pw.SizedBox(height: 12),
            ...reporte.citas.take(10).map((cita) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('${cita.doctor} – ${cita.especialidad}',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold)),
                      pw.Text(
                          'Fecha: ${cita.fechaFormato} ${cita.horaFormato}'),
                      if (cita.lugar != null && cita.lugar!.isNotEmpty)
                        pw.Text('Lugar: ${cita.lugar}'),
                    ],
                  ),
                )),
            pw.SizedBox(height: 24),
          ],

          // Pie de página
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(
              'Generado por Medical Reminders',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _sectionTitle(String text) => pw.Text(
        text,
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
      );

  pw.TableRow _headerRow(List<String> cells) => pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
        children: cells
            .map((c) => pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(c,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold)),
                ))
            .toList(),
      );

  pw.TableRow _dataRow(List<String> cells) => pw.TableRow(
        children: cells
            .map((c) => pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(c),
                ))
            .toList(),
      );
}
