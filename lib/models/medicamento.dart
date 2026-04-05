class Medicamento {
  final String id;
  final String userId;
  final String nombre;
  final String dosis;
  final List<String> horarios;
  final String? notas;
  final DateTime createdAt;

  Medicamento({
    required this.id,
    required this.userId,
    required this.nombre,
    required this.dosis,
    required this.horarios,
    this.notas,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'nombre': nombre,
      'dosis': dosis,
      'horarios': horarios.join(','),
      'notas': notas,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Medicamento.fromMap(Map<String, dynamic> map) {
    return Medicamento(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      nombre: map['nombre'] as String,
      dosis: map['dosis'] as String,
      horarios: (map['horarios'] as String).split(','),
      notas: map['notas'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Medicamento copyWith({
    String? id,
    String? userId,
    String? nombre,
    String? dosis,
    List<String>? horarios,
    String? notas,
    DateTime? createdAt,
  }) {
    return Medicamento(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nombre: nombre ?? this.nombre,
      dosis: dosis ?? this.dosis,
      horarios: horarios ?? this.horarios,
      notas: notas ?? this.notas,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
