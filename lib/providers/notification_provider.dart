import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();
  bool _enabled = false;

  bool get enabled => _enabled;

  Future<void> initialize() async {
    try {
      await _service.initialize();
      _enabled = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error inicializando notificaciones: $e');
      _enabled = false;
    }
  }

  // Programar notificaciones diarias para medicamento
  Future<void> scheduleForMedicamento({
    required String medicamentoId,
    required String nombre,
    required String dosis,
    required List<String> horarios,
  }) async {
    if (!_enabled) return;

    for (final hora in horarios) {
      final id = _notificationId(medicamentoId, hora);
      await _service.scheduleNotification(
        id: id,
        title: 'Medicamento: $nombre',
        body: 'Dosis: $dosis a las $hora',
        hora: hora,
        payload: medicamentoId,
      );
    }
  }

  // Cancelar notificaciones de medicamento por horarios
  Future<void> cancelForMedicamento({
    required String medicamentoId,
    required List<String> horarios,
  }) async {
    for (final hora in horarios) {
      final id = _notificationId(medicamentoId, hora);
      await _service.cancelNotification(id);
    }
  }

  // Cancelar notificación por ID específico (para citas)
  Future<void> cancelNotificationId(int id) async {
    await _service.cancelNotification(id);
  }

  // Programar recordatorio de cita (notificación única)
  Future<void> scheduleReminder({
    required String citaId,
    required String doctor,
    required String especialidad,
    required DateTime citaDateTime,
    required int minutosAntes,
  }) async {
    if (!_enabled) return;

    final reminderDateTime =
        citaDateTime.subtract(Duration(minutes: minutosAntes));

    if (reminderDateTime.isBefore(DateTime.now())) {
      debugPrint('Recordatorio en el pasado, no se programa');
      return;
    }

    final id = citaId.hashCode.abs() % 2147483647;
    final tiempoTexto = minutosAntes >= 60
        ? '${minutosAntes ~/ 60} hora(s)'
        : '$minutosAntes minutos';

    await _service.scheduleOneTimeNotification(
      id: id,
      title: 'Recordatorio: Cita $especialidad',
      body: 'Cita con $doctor en $tiempoTexto',
      scheduledDateTime: reminderDateTime,
      payload: citaId,
    );
  }

  Future<void> showTestNotification() async {
    if (!_enabled) return;
    await _service.showNotification(
      id: 9999,
      title: 'Prueba de Notificación',
      body: 'Las notificaciones están funcionando correctamente',
    );
  }

  Future<int> pendingCount() async {
    final pending = await _service.getPendingNotifications();
    return pending.length;
  }

  int _notificationId(String medicamentoId, String hora) {
    return '${medicamentoId}_$hora'.hashCode.abs() % 2147483647;
  }
}
