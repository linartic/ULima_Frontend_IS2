import 'package:get/get.dart';
import '../../models/evaluation_model.dart';
import '../../services/evaluations_service.dart';
import '../../services/courses_service.dart';

class CalculadoraController extends GetxController {
  // Lista reactiva de cursos obtenidos del modelo
  late var cursos = <Map<String, dynamic>>[].obs;
  
  // Servicio para obtener datos del sílabo
  late EvaluationSyllabusService _syllabusService;
  late CoursesService _coursesService;
  
  // Map de sílabus por curso ID para acceso rápido
  late var syllabusData = <String, CourseSyllabus>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // Inicializa los servicios
    _syllabusService = EvaluationSyllabusService();
    _coursesService = CoursesService();
    // Carga datos del sílabo
    _cargarDatosSyllabus();
    // Inicializa los cursos desde el servicio
    _inicializarCursos();
  }

  /// Carga los datos del sílabo de forma asincrónica
  void _cargarDatosSyllabus() async {
    try {
      await _syllabusService.loadEvaluationData();
      // Poblar el map de sílabus
      for (var syllabus in _syllabusService.allSyllabuses) {
        syllabusData[syllabus.cursoId] = syllabus;
      }
      print('✓ Datos del sílabo cargados en el controlador');
    } catch (e) {
      print('✗ Error al cargar datos del sílabo: $e');
    }
  }

  void _inicializarCursos() {
    final cursosData = _coursesService.allCourses;
    cursos.value = cursosData.map((curso) {
      var notasRx = <Map<String, dynamic>>[].obs;
      if (curso['notas'] != null) {
        notasRx.addAll(List<Map<String, dynamic>>.from(curso['notas']));
      }
      
      return {
        'id': curso['id']?.toString() ?? '',
        'nombre': curso['nombre']?.toString() ?? 'Curso sin nombre',
        'ciclo': curso['ciclo']?.toString() ?? '',
        'seccion': curso['seccion']?.toString() ?? 'Sin sección', 
        'notas': notasRx,
      };
    }).toList();
  }

  double calcularPromedio(List notas) {
    if (notas.isEmpty) return 0.0;
    double suma = 0;
    for (var n in notas) {
      suma += (n['valor'] * (n['peso'] / 100));
    }
    return suma;
  }

  double sumaPesos(List notas) {
    return notas.fold(0, (sum, item) => sum + item['peso']);
  }

  void agregarNota(int cursoIndex, String titulo, int peso, double valor, String evaluacionId) {
    if (cursoIndex >= 0 && cursoIndex < cursos.length) {
      final notas = cursos[cursoIndex]['notas'] as RxList<dynamic>;
      notas.add({
        'titulo': titulo,
        'peso': peso,
        'valor': valor,
        'evaluacionId': evaluacionId,
      });
      cursos.refresh();
    }
  }

  void eliminarNota(int cursoIndex, int notaIndex) {
    if (cursoIndex >= 0 && cursoIndex < cursos.length) {
      final notas = cursos[cursoIndex]['notas'] as RxList<dynamic>;
      if (notaIndex >= 0 && notaIndex < notas.length) {
        notas.removeAt(notaIndex);
        cursos.refresh();
      }
    }
  }

  /// Obtiene el sílabo de un curso por su índice
  CourseSyllabus? getSyllabusForCourse(int cursoIndex) {
    if (cursoIndex >= 0 && cursoIndex < cursos.length) {
      final cursoId = cursos[cursoIndex]['id'] as String?;
      if (cursoId != null && syllabusData.containsKey(cursoId)) {
        return syllabusData[cursoId];
      }
    }
    return null;
  }

  /// Obtiene las evaluaciones disponibles de un curso
  List<EvaluationComponent> getEvaluationsForCourse(int cursoIndex) {
    final syllabus = getSyllabusForCourse(cursoIndex);
    return syllabus?.evaluaciones ?? [];
  }

  /// Verifica si hay datos de sílabo cargados
  bool hasSyllabusData(int cursoIndex) {
    if (cursoIndex >= 0 && cursoIndex < cursos.length) {
      final cursoId = cursos[cursoIndex]['id'] as String?;
      return cursoId != null && syllabusData.containsKey(cursoId);
    }
    return false;
  }

  /// Obtiene los IDs de evaluaciones que ya tienen notas registradas
  List<String> getRegisteredEvaluationIds(int cursoIndex) {
    if (cursoIndex >= 0 && cursoIndex < cursos.length) {
      final notas = cursos[cursoIndex]['notas'] as List?;
      return (notas ?? [])
          .map((nota) => nota['evaluacionId'] as String? ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
    }
    return [];
  }

  /// Obtiene las evaluaciones disponibles que NO tienen notas registradas
  List<EvaluationComponent> getAvailableEvaluations(int cursoIndex) {
    final allEvaluations = getEvaluationsForCourse(cursoIndex);
    final registeredIds = getRegisteredEvaluationIds(cursoIndex);
    return allEvaluations
        .where((eval) => !registeredIds.contains(eval.id))
        .toList();
  }
}

