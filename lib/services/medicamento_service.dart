import 'package:uuid/uuid.dart';
import '../models/medicamento.dart';
import 'database_service.dart';

class MedicamentoService {
  final DatabaseService _dbService = DatabaseService();

  MedicamentoService();

  Future<void> addMedicamento({
    required String userId,
    required String nombre,
    required String dosis,
    required List<String> horarios,
    String? notas,
  }) async {
    final medicamento = Medicamento(
      id: const Uuid().v4(),
      userId: userId,
      nombre: nombre,
      dosis: dosis,
      horarios: horarios,
      notas: notas,
      createdAt: DateTime.now(),
    );

    final db = await _dbService.database;
    await db.insert('medicamentos', medicamento.toMap());
  }

  Future<List<Medicamento>> getMedicamentos(String userId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'medicamentos',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => Medicamento.fromMap(m)).toList();
  }

  Future<void> updateMedicamento({
    required String id,
    required String nombre,
    required String dosis,
    required List<String> horarios,
    String? notas,
  }) async {
    final db = await _dbService.database;
    await db.update(
      'medicamentos',
      {
        'nombre': nombre,
        'dosis': dosis,
        'horarios': horarios.join(','),
        'notas': notas,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Medicamento?> getMedicamentoById(String id) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'medicamentos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Medicamento.fromMap(maps.first);
  }

  Future<void> deleteMedicamento(String id) async {
    final db = await _dbService.database;
    await db.delete(
      'medicamentos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
