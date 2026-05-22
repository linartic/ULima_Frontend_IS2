import 'package:get/get.dart';
import '../../models/evaluation_model.dart';
import '../../services/evaluations_service.dart';
import '../../services/courses_service.dart';
import '../../services/notas_service.dart';
import '../../services/auth_service.dart';

class CalculadoraController extends GetxController {
  late var cursos = <Map<String, dynamic>>[].obs;

  late EvaluationSyllabusService _syllabusService;
  late CoursesService _coursesService;
  late NotasService _notasService;

  late String _idEstudianteActual;

  late var syllabusData = <String, CourseSyllabus>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _syllabusService = EvaluationSyllabusService();
    _coursesService = CoursesService();
    _notasService = NotasService();

    _cargarDatosSyllabus();
    _inicializarCursos();
  }

  void _cargarDatosSyllabus() async {
    try {
      await _syllabusService.loadEvaluationData();
      for (var syllabus in _syllabusService.allSyllabuses) {
        syllabusData[syllabus.cursoId] = syllabus;
      }
      print('✓ Datos del sílabo cargados en el controlador');
    } catch (e) {
      print('✗ Error al cargar datos del sílabo: $e');
    }
  }

  void _inicializarCursos() async {
    try {
      final user = AuthService.to.currentUser;

      final List<Map<String, dynamic>> seccionesInscritas =
          user?.courseProgress?.currentCourses ?? [];
      _idEstudianteActual =
          await _notasService.obtenerIdEstudianteActual() ?? 'default';
      final cursosData = _coursesService.allCourses;
      final notasGuardadas = await _notasService.cargarNotas(
        _idEstudianteActual,
      );

      List<Map<String, dynamic>> cursosExpandidos = [];

      for (var curso in cursosData) {
        List<dynamic> seccionesDelCurso = curso['secciones'] ?? [];

        for (var seccion in seccionesDelCurso) {
          bool estaInscrito = seccionesInscritas.any(
            (inscrito) => inscrito['idSeccion'] == seccion['idSeccion'],
          );

          if (!estaInscrito) continue;

          var notasRx = <Map<String, dynamic>>[].obs;

          Map<String, dynamic>? cursoBuscado = notasGuardadas.firstWhereOrNull(
            (n) => n['id'] == seccion['idSeccion'],
          );

          if (cursoBuscado != null && cursoBuscado['notas'] != null) {
            notasRx.addAll(
              List<Map<String, dynamic>>.from(cursoBuscado['notas']),
            );
          }

          cursosExpandidos.add({
            'id': seccion['idSeccion'],
            'nombre': curso['nombre']?.toString() ?? 'Curso sin nombre',
            'ciclo': curso['ciclo']?.toString() ?? '2026-1',
            'codigoSeccion':
                seccion['codigoSeccion']?.toString() ?? 'Sin sección',
            'notas': notasRx,
          });
        }
      }

      cursos.value = cursosExpandidos;
      print(
        '✓ Cursos y secciones cargados correctamente: ${cursos.length} secciones.',
      );
    } catch (e) {
      print('✗ Error al inicializar cursos: $e');
    }
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
    return notas.fold(0, (sum, item) => sum + (item['peso'] as num));
  }

  void agregarNota(
    int cursoIndex,
    String titulo,
    int peso,
    double valor,
    String evaluacionId,
  ) {
    if (cursoIndex >= 0 && cursoIndex < cursos.length) {
      final notas = cursos[cursoIndex]['notas'] as RxList<dynamic>;
      notas.add({
        'titulo': titulo,
        'peso': peso,
        'valor': valor,
        'evaluacionId': evaluacionId,
      });
      cursos.refresh();
      _guardarNotasLocal();
    }
  }

  void eliminarNota(int cursoIndex, int notaIndex) {
    if (cursoIndex >= 0 && cursoIndex < cursos.length) {
      final notas = cursos[cursoIndex]['notas'] as RxList<dynamic>;
      if (notaIndex >= 0 && notaIndex < notas.length) {
        notas.removeAt(notaIndex);
        cursos.refresh();
        _guardarNotasLocal();
      }
    }
  }

  void _guardarNotasLocal() async {
    try {
      await _notasService.guardarNotas(_idEstudianteActual, cursos);
    } catch (e) {
      print('✗ Error al guardar notas localmente: $e');
    }
  }

  CourseSyllabus? getSyllabusForCourse(int cursoIndex) {
    if (cursoIndex >= 0 && cursoIndex < cursos.length) {
      final cursoId = cursos[cursoIndex]['id'] as String?;
      if (cursoId != null && syllabusData.containsKey(cursoId)) {
        return syllabusData[cursoId];
      }
    }
    return null;
  }

  List<EvaluationComponent> getEvaluationsForCourse(int cursoIndex) {
    final syllabus = getSyllabusForCourse(cursoIndex);
    return syllabus?.evaluaciones ?? [];
  }

  bool hasSyllabusData(int cursoIndex) {
    if (cursoIndex >= 0 && cursoIndex < cursos.length) {
      final cursoId = cursos[cursoIndex]['id'] as String?;
      return cursoId != null && syllabusData.containsKey(cursoId);
    }
    return false;
  }

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

  List<EvaluationComponent> getAvailableEvaluations(int cursoIndex) {
    final allEvaluations = getEvaluationsForCourse(cursoIndex);
    final registeredIds = getRegisteredEvaluationIds(cursoIndex);
    return allEvaluations
        .where((eval) => !registeredIds.contains(eval.id))
        .toList();
  }
}
