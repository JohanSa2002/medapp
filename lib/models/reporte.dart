import 'medicamento.dart';
import 'cita.dart';
import 'registro_dato.dart';

class Reporte {
  final String userId;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final List<Medicamento> medicamentos;
  final List<Cita> citas;
  final List<RegistroDato> registrosGlucosa;
  final List<RegistroDato> registrosPeso;
  final DateTime generadoEn;

  Reporte({
    required this.userId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.medicamentos,
    required this.citas,
    required this.registrosGlucosa,
    required this.registrosPeso,
    required this.generadoEn,
  });

  List<Cita> get citasPendientes => citas.where((c) => !c.yaPaso).toList();
  List<Cita> get citasCompletadas => citas.where((c) => c.yaPaso).toList();

  double? get promedioGlucosa {
    if (registrosGlucosa.isEmpty) return null;
    return registrosGlucosa.fold<double>(0, (s, r) => s + r.valor) /
        registrosGlucosa.length;
  }

  double? get maxGlucosa {
    if (registrosGlucosa.isEmpty) return null;
    return registrosGlucosa.map((r) => r.valor).reduce((a, b) => a > b ? a : b);
  }

  double? get minGlucosa {
    if (registrosGlucosa.isEmpty) return null;
    return registrosGlucosa.map((r) => r.valor).reduce((a, b) => a < b ? a : b);
  }

  double? get promedioPeso {
    if (registrosPeso.isEmpty) return null;
    return registrosPeso.fold<double>(0, (s, r) => s + r.valor) /
        registrosPeso.length;
  }

  double? get maxPeso {
    if (registrosPeso.isEmpty) return null;
    return registrosPeso.map((r) => r.valor).reduce((a, b) => a > b ? a : b);
  }

  double? get minPeso {
    if (registrosPeso.isEmpty) return null;
    return registrosPeso.map((r) => r.valor).reduce((a, b) => a < b ? a : b);
  }

  double? get cambioPeso {
    if (registrosPeso.length < 2) return null;
    // registrosPeso is ordered DESC, so first = most recent, last = oldest
    return registrosPeso.first.valor - registrosPeso.last.valor;
  }

  int get medicamentosActivos => medicamentos.length;

  double get porcentajeCitasCumplidas {
    if (citas.isEmpty) return 0;
    return (citasCompletadas.length / citas.length) * 100;
  }

  int get glucosasEnRango =>
      registrosGlucosa.where((r) => r.estaEnRango).length;

  double get porcentajeGlucosaEnRango {
    if (registrosGlucosa.isEmpty) return 0;
    return (glucosasEnRango / registrosGlucosa.length) * 100;
  }

  String get periodoTexto =>
      '${_fmt(fechaInicio)} - ${_fmt(fechaFin)}';

  String _fmt(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String get generadoEnTexto {
    final d = generadoEn;
    return '${_fmt(d)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
