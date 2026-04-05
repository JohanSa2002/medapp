import 'package:flutter/material.dart';
import '../models/reporte.dart';
import '../services/reporte_service.dart';

class ReporteProvider extends ChangeNotifier {
  final ReporteService _service = ReporteService();

  Reporte? _reporteActual;
  bool _isLoading = false;

  Reporte? get reporteActual => _reporteActual;
  bool get isLoading => _isLoading;

  Future<void> _run(Future<Reporte> Function() fn) async {
    _isLoading = true;
    notifyListeners();
    try {
      _reporteActual = await fn();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generarReporte({
    required String userId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) =>
      _run(() => _service.generarReporte(
            userId: userId,
            fechaInicio: fechaInicio,
            fechaFin: fechaFin,
          ));

  Future<void> generarReporteSemanal(String userId) =>
      _run(() => _service.reporteSemanal(userId));

  Future<void> generarReporteMensual(String userId) =>
      _run(() => _service.reporteMensual(userId));

  Future<void> generarReporteTrimestral(String userId) =>
      _run(() => _service.reporteTrimestral(userId));

  Future<void> generarReporteAnual(String userId) =>
      _run(() => _service.reporteAnual(userId));

  void limpiarReporte() {
    _reporteActual = null;
    notifyListeners();
  }
}
