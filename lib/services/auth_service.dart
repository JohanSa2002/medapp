import 'package:firebase_auth/firebase_auth.dart';
import 'database_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final DatabaseService _dbService = DatabaseService();

  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges();
  }

  Future<void> register(
    String email,
    String password, {
    required String nombre,
    required String apellido,
  }) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await userCredential.user!.updateDisplayName('$nombre $apellido');

    final db = await _dbService.database;
    await db.insert('users', {
      'id': userCredential.user!.uid,
      'email': email,
      'nombre': nombre,
      'apellido': apellido,
    });
  }

  Future<void> login(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Future<Map<String, String?>> getUserProfile() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return {};
    final db = await _dbService.database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [user.uid]);
    if (rows.isEmpty) return {'email': user.email};
    return {
      'email': rows.first['email'] as String?,
      'nombre': rows.first['nombre'] as String?,
      'apellido': rows.first['apellido'] as String?,
    };
  }

  Future<void> updateProfile({
    required String nombre,
    required String apellido,
  }) async {
    final user = _firebaseAuth.currentUser!;
    await user.updateDisplayName('$nombre $apellido');
    final db = await _dbService.database;
    await db.update(
      'users',
      {'nombre': nombre, 'apellido': apellido},
      where: 'id = ?',
      whereArgs: [user.uid],
    );
  }

  Future<void> changePassword(String newPassword) async {
    await _firebaseAuth.currentUser!.updatePassword(newPassword);
  }
}
