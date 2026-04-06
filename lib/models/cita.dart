class Cita {
  final String id;
  final String userId;
  final String doctor;
  final String especialidad;
  final DateTime fecha;
  final String? lugar;
  final String? telefono;
  final String? notas;
  final int minutosAntes;
  final DateTime createdAt;

  Cita({
    required this.id,
    required this.userId,
    required this.doctor,
    required this.especialidad,
    required this.fecha,
    this.lugar,
    this.telefono,
    this.notas,
    this.minutosAntes = 1440,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'doctor': doctor,
      'especialidad': especialidad,
      'fecha': fecha.toIso8601String(),
      'lugar': lugar,
      'telefono': telefono,
      'notas': notas,
      'minutos_antes': minutosAntes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Cita.fromMap(Map<String, dynamic> map) {
    return Cita(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      doctor: map['doctor'] as String,
      especialidad: map['especialidad'] as String,
      fecha: DateTime.parse(map['fecha'] as String),
      lugar: map['lugar'] as String?,
      telefono: map['telefono'] as String?,
      notas: map['notas'] as String?,
      minutosAntes: map['minutos_antes'] as int? ?? 1440,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Cita copyWith({
    String? id,
    String? userId,
    String? doctor,
    String? especialidad,
    DateTime? fecha,
    String? lugar,
    String? telefono,
    String? notas,
    int? minutosAntes,
    DateTime? createdAt,
  }) {
    return Cita(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      doctor: doctor ?? this.doctor,
      especialidad: especialidad ?? this.especialidad,
      fecha: fecha ?? this.fecha,
      lugar: lugar ?? this.lugar,
      telefono: telefono ?? this.telefono,
      notas: notas ?? this.notas,
      minutosAntes: minutosAntes ?? this.minutosAntes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get esHoy {
    final hoy = DateTime.now();
    return fecha.year == hoy.year &&
        fecha.month == hoy.month &&
        fecha.day == hoy.day;
  }

  bool get yaPaso => fecha.isBefore(DateTime.now());

  String get estado {
    if (yaPaso) return 'Completada';
    if (esHoy) return 'Hoy';
    final dias = fecha.difference(DateTime.now()).inDays;
    if (dias == 0) return 'Hoy';
    if (dias == 1) return 'Mañana';
    return 'En $dias días';
  }

  String get fechaFormato {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }

  String get horaFormato {
    int hour = fecha.hour;
    final minute = fecha.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) hour = 12;
    else if (hour > 12) hour -= 12;
    return '$hour:$minute $period';
  }
}
