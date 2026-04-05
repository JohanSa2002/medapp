import '../models/reporte.dart';
import '../models/registro_dato.dart';
import 'medicamento_service.dart';
import 'cita_service.dart';
import 'registro_service.dart';

class ReporteService {
  final MedicamentoService _medicamentoService = MedicamentoService();
  final CitaService _citaService = CitaService();
  final RegistroService _registroService = RegistroService();

  ReporteService();

  Future<Reporte> generarReporte({
    required String userId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    final medicamentos = await _medicamentoService.getMedicamentos(userId);
    final todasCitas = await _citaService.getCitas(userId);
    final citasFiltradas = todasCitas
        .where((c) =>
            !c.fecha.isBefore(fechaInicio) && !c.fecha.isAfter(fechaFin))
        .toList();

    final todaGlucosa =
        await _registroService.getRegistrosPorTipo(userId, TipoDato.glucosa);
    final glucosaFiltrada = todaGlucosa
        .where((r) =>
            !r.fecha.isBefore(fechaInicio) && !r.fecha.isAfter(fechaFin))
        .toList();

    final todoPeso =
        await _registroService.getRegistrosPorTipo(userId, TipoDato.peso);
    final pesoFiltrado = todoPeso
        .where((r) =>
            !r.fecha.isBefore(fechaInicio) && !r.fecha.isAfter(fechaFin))
        .toList();

    return Reporte(
      userId: userId,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      medicamentos: medicamentos,
      citas: citasFiltradas,
      registrosGlucosa: glucosaFiltrada,
      registrosPeso: pesoFiltrado,
      generadoEn: DateTime.now(),
    );
  }

  Future<Reporte> reporteSemanal(String userId) async {
    final hoy = DateTime.now();
    return generarReporte(
      userId: userId,
      fechaInicio: hoy.subtract(const Duration(days: 7)),
      fechaFin: hoy,
    );
  }

  Future<Reporte> reporteMensual(String userId) async {
    final hoy = DateTime.now();
    return generarReporte(
      userId: userId,
      fechaInicio: hoy.subtract(const Duration(days: 30)),
      fechaFin: hoy,
    );
  }

  Future<Reporte> reporteTrimestral(String userId) async {
    final hoy = DateTime.now();
    return generarReporte(
      userId: userId,
      fechaInicio: hoy.subtract(const Duration(days: 90)),
      fechaFin: hoy,
    );
  }

  Future<Reporte> reporteAnual(String userId) async {
    final hoy = DateTime.now();
    return generarReporte(
      userId: userId,
      fechaInicio: hoy.subtract(const Duration(days: 365)),
      fechaFin: hoy,
    );
  }
}
