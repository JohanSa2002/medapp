import 'package:flutter/material.dart';
import '../models/medicamento.dart';
import '../services/medicamento_service.dart';
import 'notification_provider.dart';

class MedicamentoProvider extends ChangeNotifier {
  final MedicamentoService _service = MedicamentoService();

  List<Medicamento> _medicamentos = [];
  bool _isLoading = false;

  List<Medicamento> get medicamentos => _medicamentos;
  bool get isLoading => _isLoading;

  Future<void> loadMedicamentos(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _medicamentos = await _service.getMedicamentos(userId);
    } catch (e) {
      debugPrint('Error cargando medicamentos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMedicamento({
    required String userId,
    required String nombre,
    required String dosis,
    required List<String> horarios,
    required NotificationProvider notificationProvider,
    String? notas,
  }) async {
    await _service.addMedicamento(
      userId: userId,
      nombre: nombre,
      dosis: dosis,
      horarios: horarios,
      notas: notas,
    );

    // Obtener el medicamento recién creado para su ID
    final lista = await _service.getMedicamentos(userId);
    final nuevo = lista.first;

    await notificationProvider.scheduleForMedicamento(
      medicamentoId: nuevo.id,
      nombre: nombre,
      dosis: dosis,
      horarios: horarios,
    );

    _medicamentos = lista;
    notifyListeners();
  }

  Future<void> updateMedicamento({
    required String id,
    required String userId,
    required String nombre,
    required String dosis,
    required List<String> horarios,
    required NotificationProvider notificationProvider,
    String? notas,
  }) async {
    final anterior = await _service.getMedicamentoById(id);
    if (anterior != null) {
      await notificationProvider.cancelForMedicamento(
        medicamentoId: id,
        horarios: anterior.horarios,
      );
    }

    await _service.updateMedicamento(
      id: id,
      nombre: nombre,
      dosis: dosis,
      horarios: horarios,
      notas: notas,
    );

    await notificationProvider.scheduleForMedicamento(
      medicamentoId: id,
      nombre: nombre,
      dosis: dosis,
      horarios: horarios,
    );

    await loadMedicamentos(userId);
  }

  Future<void> deleteMedicamento({
    required String id,
    required String userId,
    required NotificationProvider notificationProvider,
  }) async {
    final medicamento = await _service.getMedicamentoById(id);
    if (medicamento != null) {
      await notificationProvider.cancelForMedicamento(
        medicamentoId: id,
        horarios: medicamento.horarios,
      );
    }

    await _service.deleteMedicamento(id);
    await loadMedicamentos(userId);
  }
}
