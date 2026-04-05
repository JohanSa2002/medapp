import 'package:uuid/uuid.dart';
import '../models/registro_dato.dart';
import 'database_service.dart';

class RegistroService {
  final DatabaseService _dbService = DatabaseService();

  RegistroService();

  Future<void> addRegistro({
    required String userId,
    required TipoDato tipo,
    required double valor,
    String? unidad,
    String? notas,
    required DateTime fecha,
  }) async {
    final registro = RegistroDato(
      id: const Uuid().v4(),
      userId: userId,
      tipo: tipo,
      valor: valor,
      unidad: unidad,
      notas: notas,
      fecha: fecha,
      createdAt: DateTime.now(),
    );
    final db = await _dbService.database;
    await db.insert('registros', registro.toMap());
  }

  Future<List<RegistroDato>> getRegistros(String userId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'registros',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'fecha DESC',
    );
    return maps.map((m) => RegistroDato.fromMap(m)).toList();
  }

  Future<List<RegistroDato>> getRegistrosPorTipo(
    String userId,
    TipoDato tipo,
  ) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'registros',
      where: 'user_id = ? AND tipo = ?',
      whereArgs: [userId, tipo.toString().split('.').last],
      orderBy: 'fecha DESC',
    );
    return maps.map((m) => RegistroDato.fromMap(m)).toList();
  }

  Future<List<RegistroDato>> getRegistrosUltimosDias(
    String userId,
    TipoDato tipo,
    int dias,
  ) async {
    final db = await _dbService.database;
    final fechaLimite = DateTime.now().subtract(Duration(days: dias));
    final maps = await db.query(
      'registros',
      where: 'user_id = ? AND tipo = ? AND fecha >= ?',
      whereArgs: [
        userId,
        tipo.toString().split('.').last,
        fechaLimite.toIso8601String(),
      ],
      orderBy: 'fecha ASC',
    );
    return maps.map((m) => RegistroDato.fromMap(m)).toList();
  }

  Future<void> updateRegistro({
    required String id,
    required double valor,
    String? unidad,
    String? notas,
    required DateTime fecha,
  }) async {
    final db = await _dbService.database;
    await db.update(
      'registros',
      {
        'valor': valor,
        'unidad': unidad,
        'notas': notas,
        'fecha': fecha.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteRegistro(String id) async {
    final db = await _dbService.database;
    await db.delete('registros', where: 'id = ?', whereArgs: [id]);
  }

  Future<double?> getPromedioRegistros(
    String userId,
    TipoDato tipo,
    int dias,
  ) async {
    final registros = await getRegistrosUltimosDias(userId, tipo, dias);
    if (registros.isEmpty) return null;
    final suma = registros.fold<double>(0, (sum, r) => sum + r.valor);
    return suma / registros.length;
  }

  Future<double?> getMaxRegistro(
    String userId,
    TipoDato tipo,
    int dias,
  ) async {
    final registros = await getRegistrosUltimosDias(userId, tipo, dias);
    if (registros.isEmpty) return null;
    return registros.map((r) => r.valor).reduce((a, b) => a > b ? a : b);
  }

  Future<double?> getMinRegistro(
    String userId,
    TipoDato tipo,
    int dias,
  ) async {
    final registros = await getRegistrosUltimosDias(userId, tipo, dias);
    if (registros.isEmpty) return null;
    return registros.map((r) => r.valor).reduce((a, b) => a < b ? a : b);
  }
}
