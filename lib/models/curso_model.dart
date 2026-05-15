class Curso {
  final String id;
  final String nombre;
  final String ciclo;
  final List<Map<String, dynamic>> notas;

  Curso({
    required this.id,
    required this.nombre,
    required this.ciclo,
    required this.notas,
  });

  // Convertir a Map para facilitar la manipulación reactiva
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'ciclo': ciclo,
      'notas': notas,
    };
  }
}

// Datos de cursos actualmente cursando
final List<Map<String, dynamic>> cursosActivos = [
  {
    'id': '650006',
    'nombre': 'CÁLCULO III',
    'ciclo': '2026-0',
    'notas': [
      {'titulo': 'Práctica Calificada 1', 'peso': 15, 'valor': 20.0},
      {'titulo': 'Práctica Calificada 2', 'peso': 15, 'valor': 15.0},
    ],
  },
  {
    'id': '650026',
    'nombre': 'INGENIERÍA DE SOFTWARE I',
    'ciclo': '2026-0',
    'notas': [
      {'titulo': 'Práctica Calificada 2', 'peso': 15, 'valor': 20.0},
    ],
  },
];
