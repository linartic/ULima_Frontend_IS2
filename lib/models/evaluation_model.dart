class EvaluationComponent {
  final String id;
  final String nombre;
  final String sigla;
  final double peso;
  final String tipo;

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

class CourseSyllabus {
  final String cursoId;
  final String cursoNombre;
  final List<EvaluationComponent> evaluaciones;

  CourseSyllabus({
    required this.cursoId,
    required this.cursoNombre,
    required this.evaluaciones,
  });

  double get pesoTotal => evaluaciones.fold(0, (sum, eval) => sum + eval.peso);

  /// Convertir desde JSON
  factory CourseSyllabus.fromJson(Map<String, dynamic> json) {
    final evaluacionesList = (json['evaluaciones'] as List<dynamic>? ?? [])
        .map(
          (eval) => EvaluationComponent.fromJson(eval as Map<String, dynamic>),
        )
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
