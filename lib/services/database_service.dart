import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'medical_reminders.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE medicamentos (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        nombre TEXT NOT NULL,
        dosis TEXT NOT NULL,
        horarios TEXT NOT NULL,
        notas TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE citas (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        doctor TEXT NOT NULL,
        especialidad TEXT NOT NULL,
        fecha TEXT NOT NULL,
        lugar TEXT,
        telefono TEXT,
        notas TEXT,
        minutos_antes INTEGER NOT NULL DEFAULT 60,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE registros (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        tipo TEXT NOT NULL,
        valor REAL NOT NULL,
        unidad TEXT,
        notas TEXT,
        fecha TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_registros_user_tipo
      ON registros(user_id, tipo, fecha)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Recrear citas con el nuevo esquema
      await db.execute('DROP TABLE IF EXISTS citas');
      await db.execute('''
        CREATE TABLE citas (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          doctor TEXT NOT NULL,
          especialidad TEXT NOT NULL,
          fecha TEXT NOT NULL,
          lugar TEXT,
          telefono TEXT,
          notas TEXT,
          minutos_antes INTEGER NOT NULL DEFAULT 60,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users(id)
        )
      ''');
      // Agregar columna notas a medicamentos si no existe
      try {
        await db.execute('ALTER TABLE medicamentos ADD COLUMN notas TEXT');
      } catch (_) {}
    }
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS registros');
      await db.execute('''
        CREATE TABLE registros (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          tipo TEXT NOT NULL,
          valor REAL NOT NULL,
          unidad TEXT,
          notas TEXT,
          fecha TEXT NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users(id)
        )
      ''');
      await db.execute('''
        CREATE INDEX idx_registros_user_tipo
        ON registros(user_id, tipo, fecha)
      ''');
    }
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}
