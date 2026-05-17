import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/evaluation_model.dart';

/// Servicio para cargar y gestionar los datos de evaluaciones del sílabo
class EvaluationSyllabusService {
  static final EvaluationSyllabusService _instance =
      EvaluationSyllabusService._internal();

  factory EvaluationSyllabusService() {
    return _instance;
  }

  EvaluationSyllabusService._internal();

  late List<CourseSyllabus> _syllabusData;
  bool _isLoaded = false;

  /// Carga el archivo JSON con los datos de evaluaciones
  Future<void> loadEvaluationData() async {
    if (_isLoaded) return;

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/evaluation_syllabus.json',
      );

      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      final cursosList = jsonData['cursos'] as List<dynamic>? ?? [];

      _syllabusData = cursosList
          .map((curso) => CourseSyllabus.fromJson(curso as Map<String, dynamic>))
          .toList();

      _isLoaded = true;
      print('✓ Datos de evaluaciones cargados: ${_syllabusData.length} cursos');
    } catch (e) {
      print('✗ Error al cargar datos de evaluaciones: $e');
      rethrow;
    }
  }

  /// Obtiene el sílabo de un curso específico por su ID
  CourseSyllabus? getSyllabusByCourseId(String cursoId) {
    try {
      return _syllabusData.firstWhere((syllabus) => syllabus.cursoId == cursoId);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene las evaluaciones de un curso específico
  List<EvaluationComponent> getEvaluationsByCourseId(String cursoId) {
    final syllabus = getSyllabusByCourseId(cursoId);
    return syllabus?.evaluaciones ?? [];
  }

  /// Obtiene todos los sílabos cargados
  List<CourseSyllabus> get allSyllabuses => _syllabusData;

  /// Verifica si los datos ya están cargados
  bool get isLoaded => _isLoaded;
}
