enum TipoDato {
  glucosa, // mg/dL
  peso, // kg
}

class RegistroDato {
  final String id;
  final String userId;
  final TipoDato tipo;
  final double valor;
  final String? unidad;
  final String? notas;
  final DateTime fecha;
  final DateTime createdAt;

  RegistroDato({
    required this.id,
    required this.userId,
    required this.tipo,
    required this.valor,
    this.unidad,
    this.notas,
    required this.fecha,
    required this.createdAt,
  });

  String get unidadFormato {
    if (unidad != null) return unidad!;
    return tipo == TipoDato.glucosa ? 'mg/dL' : 'kg';
  }

  bool get estaEnRango {
    switch (tipo) {
      case TipoDato.glucosa:
        return valor >= 70 && valor <= 100;
      case TipoDato.peso:
        return true;
    }
  }

  String get categoriaGlucosa {
    if (valor < 70) return 'Hipoglucemia';
    if (valor <= 100) return 'Normal';
    if (valor <= 125) return 'Prediabetes';
    return 'Hiperglucemia';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'tipo': tipo.toString().split('.').last,
      'valor': valor,
      'unidad': unidadFormato,
      'notas': notas,
      'fecha': fecha.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory RegistroDato.fromMap(Map<String, dynamic> map) {
    final tipoString = map['tipo'] as String;
    final tipo = TipoDato.values.firstWhere(
      (e) => e.toString().split('.').last == tipoString,
    );
    return RegistroDato(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      tipo: tipo,
      valor: (map['valor'] as num).toDouble(),
      unidad: map['unidad'] as String?,
      notas: map['notas'] as String?,
      fecha: DateTime.parse(map['fecha'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  RegistroDato copyWith({
    String? id,
    String? userId,
    TipoDato? tipo,
    double? valor,
    String? unidad,
    String? notas,
    DateTime? fecha,
    DateTime? createdAt,
  }) {
    return RegistroDato(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tipo: tipo ?? this.tipo,
      valor: valor ?? this.valor,
      unidad: unidad ?? this.unidad,
      notas: notas ?? this.notas,
      fecha: fecha ?? this.fecha,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get fechaFormato {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }

  String get horaFormato {
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }

  String get textoCompleto => '$valor $unidadFormato - $fechaFormato $horaFormato';
}
