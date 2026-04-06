import 'package:flutter/material.dart';
import '../models/cita.dart';
import '../services/cita_service.dart';
import 'notification_provider.dart';

class CitaProvider extends ChangeNotifier {
  final CitaService _service = CitaService();

  List<Cita> _citas = [];
  bool _isLoading = false;

  List<Cita> get citas => _citas;
  bool get isLoading => _isLoading;

  List<Cita> get citasProximas {
    final ahora = DateTime.now();
    return _citas.where((c) => c.fecha.isAfter(ahora)).toList();
  }

  Cita? get proximaCita => citasProximas.isEmpty ? null : citasProximas.first;

  List<Cita> get citasHoy =>
      _citas.where((c) => c.esHoy && !c.yaPaso).toList();

  Future<void> loadCitas(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _citas = await _service.getCitas(userId);
    } catch (e) {
      debugPrint('Error cargando citas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCita({
    required String userId,
    required String doctor,
    required String especialidad,
    required DateTime fecha,
    required NotificationProvider notificationProvider,
    String? lugar,
    String? telefono,
    String? notas,
    int minutosAntes = 1440,
  }) async {
    await _service.addCita(
      userId: userId,
      doctor: doctor,
      especialidad: especialidad,
      fecha: fecha,
      lugar: lugar,
      telefono: telefono,
      notas: notas,
      minutosAntes: minutosAntes,
    );

    await loadCitas(userId);

    // Programar recordatorio con el ID de la cita recién creada
    if (_citas.isNotEmpty) {
      final nueva = _citas.firstWhere(
        (c) => c.doctor == doctor && c.especialidad == especialidad,
        orElse: () => _citas.first,
      );
      await notificationProvider.scheduleReminder(
        citaId: nueva.id,
        doctor: doctor,
        especialidad: especialidad,
        citaDateTime: fecha,
        minutosAntes: minutosAntes,
      );
    }
  }

  Future<void> updateCita({
    required String id,
    required String userId,
    required String doctor,
    required String especialidad,
    required DateTime fecha,
    required NotificationProvider notificationProvider,
    String? lugar,
    String? telefono,
    String? notas,
    int minutosAntes = 1440,
  }) async {
    // Cancelar recordatorio anterior
    await notificationProvider.cancelNotificationId(
      id.hashCode.abs() % 2147483647,
    );

    await _service.updateCita(
      id: id,
      doctor: doctor,
      especialidad: especialidad,
      fecha: fecha,
      lugar: lugar,
      telefono: telefono,
      notas: notas,
      minutosAntes: minutosAntes,
    );

    // Programar nuevo recordatorio
    await notificationProvider.scheduleReminder(
      citaId: id,
      doctor: doctor,
      especialidad: especialidad,
      citaDateTime: fecha,
      minutosAntes: minutosAntes,
    );

    await loadCitas(userId);
  }

  Future<void> deleteCita({
    required String id,
    required String userId,
    required NotificationProvider notificationProvider,
  }) async {
    await notificationProvider.cancelNotificationId(
      id.hashCode.abs() % 2147483647,
    );
    await _service.deleteCita(id);
    await loadCitas(userId);
  }
}
