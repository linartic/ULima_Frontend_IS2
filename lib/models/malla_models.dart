// lib/models/malla_models.dart
// Modelos del dominio de la malla curricular.

import 'package:flutter/material.dart';

/// Estado de un curso dentro de la malla para un alumno.
/// - locked    → bloqueado: no cumple prerrequisitos
/// - unlocked  → disponible: cumple prereqs, aún no lo lleva
/// - current   → cursando ahora
/// - approved  → finalizado/aprobado
enum CourseStatus { locked, unlocked, current, approved }

extension CourseStatusX on CourseStatus {
  String get label {
    switch (this) {
      case CourseStatus.locked:
        return 'Bloqueado';
      case CourseStatus.unlocked:
        return 'Disponible';
      case CourseStatus.current:
        return 'Cursando';
      case CourseStatus.approved:
        return 'Aprobado';
    }
  }

  /// Color principal para pintar la card.
  Color get color {
    switch (this) {
      case CourseStatus.approved:
        return const Color(0xFF10B981);
      case CourseStatus.current:
        return const Color(0xFFF59E0B);
      case CourseStatus.unlocked:
        return const Color(0xFF0EA5E9);
      case CourseStatus.locked:
        return const Color(0xFF94A3B8);
    }
  }

  /// Borde más oscuro (1 stop más fuerte que el fondo).
  Color get borderColor {
    switch (this) {
      case CourseStatus.approved:
        return const Color(0xFF059669);
      case CourseStatus.current:
        return const Color(0xFFD97706);
      case CourseStatus.unlocked:
        return const Color(0xFF0284C7);
      case CourseStatus.locked:
        return const Color(0xFF64748B);
    }
  }
}

/// Categoría visual del curso (define el grupo al que pertenece en la malla).
enum CourseCategory { eegg, faculty, common, elective }

CourseCategory _parseCategory(String? raw) {
  switch (raw) {
    case 'EEGG':
      return CourseCategory.eegg;
    case 'COMMON':
      return CourseCategory.common;
    case 'ELECTIVE':
      return CourseCategory.elective;
    case 'FACULTY':
    default:
      return CourseCategory.faculty;
  }
}

/// Marcadores especiales en la lista de prerrequisitos.
const String prereqVCiclo = '_V_CICLO_';
const String prereqVICiclo = '_VI_CICLO_';

/// Nodo de la malla con la metadata estática del curso.
class CourseNode {
  CourseNode({
    required this.id,
    required this.code,
    required this.name,
    required this.credits,
    required this.level,
    required this.prerequisites,
    required this.category,
    required this.row,
    required this.specialties,
    this.externalFaculty,
  });

  final String id;
  final String code;
  final String name;
  final int credits;
  final int level;
  final List<String> prerequisites;
  final CourseCategory category;

  /// Fila visual del curso dentro del grid (0..N por nivel).
  final int row;

  /// Especialidades que recomiendan este electivo. Vacío para obligatorios.
  final List<String> specialties;

  /// Facultad externa si el curso pertenece a otra carrera (e.g. "Comunicaciones").
  final String? externalFaculty;

  bool get isElective => category == CourseCategory.elective;
  bool get isExternal => externalFaculty != null;

  /// True si el prereq es un marcador "haber culminado X ciclo".
  bool _isCicloMarker(String p) => p.startsWith('_') && p.endsWith('_CICLO_');

  /// Lista de prerrequisitos "concretos" (cursos, no marcadores).
  List<String> get coursePrerequisites =>
      prerequisites.where((p) => !_isCicloMarker(p)).toList();

  /// Si está marcado como _V_CICLO_ o _VI_CICLO_, devuelve el ciclo mínimo
  /// requerido. Null si no aplica.
  int? get requiredCompletedLevel {
    if (prerequisites.contains(prereqVCiclo)) return 5;
    if (prerequisites.contains(prereqVICiclo)) return 6;
    return null;
  }

  factory CourseNode.fromJson(Map<String, dynamic> json) {
    return CourseNode(
      id: json['id'] as String,
      code: (json['code'] ?? '').toString(),
      name: json['name'] as String,
      credits: (json['credits'] as num?)?.toInt() ?? 3,
      level: (json['level'] as num).toInt(),
      prerequisites:
          (json['prerequisites'] as List?)?.cast<String>() ?? const <String>[],
      category: _parseCategory(json['category'] as String?),
      row: (json['row'] as num?)?.toInt() ?? 0,
      specialties:
          (json['specialties'] as List?)?.cast<String>() ?? const <String>[],
      externalFaculty: json['externalFaculty'] as String?,
    );
  }
}

/// Progreso académico del alumno tal como viene de users.json.
class CourseProgress {
  CourseProgress({
    required this.approvedLevels,
    required this.approvedElectives,
    required this.currentCourses,
  });

  /// Niveles cuyos cursos obligatorios están todos aprobados.
  final Set<int> approvedLevels;

  /// Electivos individuales que el alumno ya aprobó.
  final Set<String> approvedElectives;

  /// Cursos (id) que el alumno está llevando en este ciclo.
  final Set<String> currentCourses;

  factory CourseProgress.empty() => CourseProgress(
        approvedLevels: <int>{},
        approvedElectives: <String>{},
        currentCourses: <String>{},
      );

  factory CourseProgress.fromJson(Map<String, dynamic>? json) {
    if (json == null) return CourseProgress.empty();
    return CourseProgress(
      approvedLevels:
          ((json['approvedLevels'] as List?) ?? const [])
              .map<int>((e) => (e as num).toInt())
              .toSet(),
      approvedElectives:
          ((json['approvedElectives'] as List?) ?? const []).cast<String>().toSet(),
      currentCourses:
          ((json['currentCourses'] as List?) ?? const []).cast<String>().toSet(),
    );
  }
}
