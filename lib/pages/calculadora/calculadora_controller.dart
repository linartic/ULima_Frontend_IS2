import 'package:get/get.dart';
import '../../models/curso_model.dart';

class CalculadoraController extends GetxController {
  // Lista reactiva de cursos obtenidos del modelo
  late var cursos = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Inicializa los cursos desde el modelo
    _inicializarCursos();
  }

  void _inicializarCursos() {
    cursos.value = cursosActivos.map((curso) {
      var notasRx = <Map<String, dynamic>>[].obs;
      if (curso['notas'] != null) {
        notasRx.addAll(List<Map<String, dynamic>>.from(curso['notas']));
      }
      return {
        'id': curso['id'],
        'nombre': curso['nombre'],
        'ciclo': curso['ciclo'],
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

  void agregarNota(int cursoIndex, String titulo, int peso, double valor) {
    if (cursoIndex >= 0 && cursoIndex < cursos.length) {
      final notas = cursos[cursoIndex]['notas'] as RxList<dynamic>;
      notas.add({
        'titulo': titulo,
        'peso': peso,
        'valor': valor,
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
}
