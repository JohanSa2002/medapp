import 'package:flutter/material.dart';
import '../models/registro_dato.dart';
import '../services/registro_service.dart';

class RegistroProvider extends ChangeNotifier {
  final RegistroService _registroService = RegistroService();

  List<RegistroDato> _registros = [];
  List<RegistroDato> _registrosGlucosa = [];
  List<RegistroDato> _registrosPeso = [];
  bool _isLoading = false;

  double? _promedioGlucosa;
  double? _maxGlucosa;
  double? _minGlucosa;
  double? _promedioPeso;
  double? _maxPeso;
  double? _minPeso;

  List<RegistroDato> get registros => _registros;
  List<RegistroDato> get registrosGlucosa => _registrosGlucosa;
  List<RegistroDato> get registrosPeso => _registrosPeso;
  bool get isLoading => _isLoading;

  double? get promedioGlucosa => _promedioGlucosa;
  double? get maxGlucosa => _maxGlucosa;
  double? get minGlucosa => _minGlucosa;
  double? get promedioPeso => _promedioPeso;
  double? get maxPeso => _maxPeso;
  double? get minPeso => _minPeso;

  Future<void> loadRegistros(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _registros = await _registroService.getRegistros(userId);
      _registrosGlucosa = await _registroService.getRegistrosPorTipo(
        userId,
        TipoDato.glucosa,
      );
      _registrosPeso = await _registroService.getRegistrosPorTipo(
        userId,
        TipoDato.peso,
      );
      await _loadEstadisticas(userId);
    } catch (e) {
      debugPrint('Error cargando registros: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadEstadisticas(String userId) async {
    _promedioGlucosa = await _registroService.getPromedioRegistros(
      userId,
      TipoDato.glucosa,
      30,
    );
    _maxGlucosa =
        await _registroService.getMaxRegistro(userId, TipoDato.glucosa, 30);
    _minGlucosa =
        await _registroService.getMinRegistro(userId, TipoDato.glucosa, 30);
    _promedioPeso = await _registroService.getPromedioRegistros(
      userId,
      TipoDato.peso,
      30,
    );
    _maxPeso =
        await _registroService.getMaxRegistro(userId, TipoDato.peso, 30);
    _minPeso =
        await _registroService.getMinRegistro(userId, TipoDato.peso, 30);
  }

  Future<void> addRegistro({
    required String userId,
    required TipoDato tipo,
    required double valor,
    String? unidad,
    String? notas,
    required DateTime fecha,
  }) async {
    await _registroService.addRegistro(
      userId: userId,
      tipo: tipo,
      valor: valor,
      unidad: unidad,
      notas: notas,
      fecha: fecha,
    );
    await loadRegistros(userId);
  }

  Future<void> updateRegistro({
    required String id,
    required String userId,
    required double valor,
    String? unidad,
    String? notas,
    required DateTime fecha,
  }) async {
    await _registroService.updateRegistro(
      id: id,
      valor: valor,
      unidad: unidad,
      notas: notas,
      fecha: fecha,
    );
    await loadRegistros(userId);
  }

  Future<void> deleteRegistro({
    required String id,
    required String userId,
  }) async {
    await _registroService.deleteRegistro(id);
    await loadRegistros(userId);
  }

  List<RegistroDato> getUltimosRegistros(TipoDato tipo, int cantidad) {
    final lista =
        tipo == TipoDato.glucosa ? _registrosGlucosa : _registrosPeso;
    return lista.take(cantidad).toList();
  }
}
