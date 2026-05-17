import '../services/courses_service.dart';

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

// Obtiene los datos de cursos desde el JSON
List<Map<String, dynamic>> getCursosActivos() {
  final service = CoursesService();
  if (!service.isLoaded) {
    print('⚠️ Advertencia: Datos de cursos no cargados aún');
    return [];
  }
  return service.allCourses;
}
