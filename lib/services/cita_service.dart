import 'package:uuid/uuid.dart';
import '../models/cita.dart';
import 'database_service.dart';

class CitaService {
  final DatabaseService _dbService = DatabaseService();

  CitaService();

  Future<void> addCita({
    required String userId,
    required String doctor,
    required String especialidad,
    required DateTime fecha,
    String? lugar,
    String? telefono,
    String? notas,
    int minutosAntes = 1440,
  }) async {
    final cita = Cita(
      id: const Uuid().v4(),
      userId: userId,
      doctor: doctor,
      especialidad: especialidad,
      fecha: fecha,
      lugar: lugar,
      telefono: telefono,
      notas: notas,
      minutosAntes: minutosAntes,
      createdAt: DateTime.now(),
    );

    final db = await _dbService.database;
    await db.insert('citas', cita.toMap());
  }

  Future<List<Cita>> getCitas(String userId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'citas',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'fecha ASC',
    );
    return maps.map((m) => Cita.fromMap(m)).toList();
  }

  Future<Cita?> getCitaById(String id) async {
    final db = await _dbService.database;
    final maps = await db.query('citas', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Cita.fromMap(maps.first);
  }

  Future<void> updateCita({
    required String id,
    required String doctor,
    required String especialidad,
    required DateTime fecha,
    String? lugar,
    String? telefono,
    String? notas,
    int minutosAntes = 1440,
  }) async {
    final db = await _dbService.database;
    await db.update(
      'citas',
      {
        'doctor': doctor,
        'especialidad': especialidad,
        'fecha': fecha.toIso8601String(),
        'lugar': lugar,
        'telefono': telefono,
        'notas': notas,
        'minutos_antes': minutosAntes,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteCita(String id) async {
    final db = await _dbService.database;
    await db.delete('citas', where: 'id = ?', whereArgs: [id]);
  }
}
