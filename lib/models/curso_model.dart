import '../services/courses_service.dart';

class Curso {
  final String id;
  final String nombre;
  final String ciclo;
  final List<Map<String, dynamic>> notas;
  final String seccion; 

  Curso({
    required this.id,
    required this.nombre,
    required this.ciclo,
    required this.notas,
    required this.seccion, 
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'ciclo': ciclo,
      'notas': notas,
      'seccion': seccion, 

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
