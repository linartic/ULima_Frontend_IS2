class EvaluationComponent {
  final String id;
  final String nombre; // Ej: "Práctica Calificada 1"
  final String sigla;  // Ej: "PC1"
  final double peso;   // Ej: 15.0 (en porcentaje)
  final String tipo;   // Ej: "practica", "examen", "trabajo", "participacion"

  EvaluationComponent({
    required this.id,
    required this.nombre,
    required this.sigla,
    required this.peso,
    required this.tipo,
  });

  /// Convertir desde JSON
  factory EvaluationComponent.fromJson(Map<String, dynamic> json) {
    return EvaluationComponent(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      sigla: json['sigla'] ?? '',
      peso: (json['peso'] as num).toDouble(),
      tipo: json['tipo'] ?? '',
    );
  }

  /// Convertir a Map para manipulación reactiva
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'sigla': sigla,
      'peso': peso,
      'tipo': tipo,
    };
  }
}

/// Modelo para el plan de evaluación de un curso (del sílabo)
class CourseSyllabus {
  final String cursoId;
  final String cursoNombre;
  final List<EvaluationComponent> evaluaciones;

  CourseSyllabus({
    required this.cursoId,
    required this.cursoNombre,
    required this.evaluaciones,
  });

  /// Obtener peso total de evaluaciones
  double get pesoTotal => evaluaciones.fold(0, (sum, eval) => sum + eval.peso);

  /// Convertir desde JSON
  factory CourseSyllabus.fromJson(Map<String, dynamic> json) {
    final evaluacionesList = (json['evaluaciones'] as List<dynamic>? ?? [])
        .map((eval) => EvaluationComponent.fromJson(eval as Map<String, dynamic>))
        .toList();

    return CourseSyllabus(
      cursoId: json['cursoId'] ?? '',
      cursoNombre: json['cursoNombre'] ?? '',
      evaluaciones: evaluacionesList,
    );
  }

  /// Convertir a Map
  Map<String, dynamic> toMap() {
    return {
      'cursoId': cursoId,
      'cursoNombre': cursoNombre,
      'evaluaciones': evaluaciones.map((e) => e.toMap()).toList(),
      'pesoTotal': pesoTotal,
    };
  }
}
