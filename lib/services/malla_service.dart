// lib/services/malla_service.dart
// Catálogo de la malla + cálculo de estados por alumno.

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';

import '../models/malla_models.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class MallaService extends GetxService {
  static MallaService get to => Get.find();

  /// Retrocompatibilidad con nombres legacy almacenados en users.json antes
  /// del Plan 2026. Los nombres nuevos (valores) coinciden exactamente con
  /// los diplomas oficiales y con el campo `specialties` del JSON de la malla.
  static const Map<String, String> _especialidadAliases = {
    'Desarrollo de Software': 'Ingeniería de Software',
    'Ciberseguridad': 'Tecnologías de la Información',
    'Ciencia de Datos': 'Sistemas de Información',
    'TI': 'Tecnologías de la Información',
    // Nombres actuales incluidos como identidad para no romper normalizeSpecialty.
    'Ingeniería de Software': 'Ingeniería de Software',
    'Sistemas de Información': 'Sistemas de Información',
    'Tecnologías de la Información': 'Tecnologías de la Información',
    'Desarrollo de Videojuegos': 'Desarrollo de Videojuegos',
  };

  final RxList<CourseNode> _courses = <CourseNode>[].obs;
  final RxList<String> _specialties = <String>[].obs;

  List<CourseNode> get courses => _courses;
  List<String> get availableSpecialties => _specialties;

  /// Carga el catálogo desde assets/data/malla_sistemas.json (idempotente).
  Future<void> load() async {
    if (_courses.isNotEmpty) return;
    final raw = await rootBundle.loadString('assets/data/malla_sistemas.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = (decoded['courses'] as List)
        .cast<Map<String, dynamic>>()
        .map(CourseNode.fromJson)
        .toList();
    _courses.assignAll(list);
    _specialties.assignAll(
      ((decoded['specialties'] as List?) ?? const []).cast<String>(),
    );
  }

  /// Cantidad máxima de filas observadas en un mismo nivel (para sizing del canvas).
  int get maxRow {
    if (_courses.isEmpty) return 0;
    return _courses.map((c) => c.row).reduce((a, b) => a > b ? a : b);
  }

  /// Normaliza la especialidad del usuario al nombre oficial del diploma.
  String normalizeSpecialty(String esp) => _especialidadAliases[esp] ?? esp;

  /// Calcula el mapa { courseId: status } para un usuario.
  Map<String, CourseStatus> computeStatuses(UserModel user) {
    final progress = user.courseProgress ?? CourseProgress.empty();

    // Lookup por id.
    final byId = <String, CourseNode>{for (final c in _courses) c.id: c};

    // Set de cursos aprobados: los niveles aprobados solo incorporan cursos
    // obligatorios; los electivos aprobados no completan ciclos académicos.
    final approved = approvedCourseIdsFor(progress);

    final result = <String, CourseStatus>{};
    for (final c in _courses) {
      // Si está en curso → current.
      if (progress.currentCourses.contains(c.id)) {
        result[c.id] = CourseStatus.current;
        continue;
      }
      // Si está aprobado → approved.
      if (approved.contains(c.id)) {
        result[c.id] = CourseStatus.approved;
        continue;
      }

      // Verificar marcadores de ciclo (electivos).
      final reqLvl = c.requiredCompletedLevel;
      if (reqLvl != null &&
          !hasCompletedMandatoryCyclesFromApprovedIds(approved, reqLvl)) {
        result[c.id] = CourseStatus.locked;
        continue;
      }

      // Verificar prerrequisitos concretos.
      final allPrereqsOk = c.coursePrerequisites.every((p) {
        if (!byId.containsKey(p)) return false;
        return approved.contains(p);
      });

      result[c.id] = allPrereqsOk ? CourseStatus.unlocked : CourseStatus.locked;
    }
    return result;
  }

  /// IDs aprobados derivados del progreso persistido.
  ///
  /// `approvedLevels` representa ciclos completos, pero cada ciclo completo
  /// solo aporta cursos obligatorios. Los electivos aprobados se agregan como
  /// cursos individuales y no sirven para completar un ciclo académico.
  Set<String> approvedCourseIdsFor(CourseProgress progress) {
    final approved = <String>{};
    for (final c in _courses) {
      if (!c.isElective && progress.approvedLevels.contains(c.level)) {
        approved.add(c.id);
      }
    }
    approved.addAll(progress.approvedElectives);
    return approved;
  }

  /// True si todos los cursos obligatorios hasta `throughLevel` están aprobados.
  ///
  /// Los electivos se excluyen siempre, incluso si pertenecen visualmente a un
  /// nivel anterior o ya fueron aprobados.
  bool hasCompletedMandatoryCyclesFromApprovedIds(
    Set<String> approvedCourseIds,
    int throughLevel,
  ) {
    return _courses
        .where((c) => !c.isElective && c.level <= throughLevel)
        .every((c) => approvedCourseIds.contains(c.id));
  }

  bool hasCompletedMandatoryCyclesFromStatuses(
    Map<String, CourseStatus> statuses,
    int throughLevel,
  ) {
    final approvedCourseIds = statuses.entries
        .where((entry) => entry.value == CourseStatus.approved)
        .map((entry) => entry.key)
        .toSet();
    return hasCompletedMandatoryCyclesFromApprovedIds(
      approvedCourseIds,
      throughLevel,
    );
  }

  /// Decide si un electivo debe mostrarse según la(s) especialidad(es)
  /// elegidas por el alumno. Si no eligió ninguna o el electivo no tiene
  /// especialidad asociada (caso 520074), siempre se muestra.
  bool electiveMatchesUserSpecialties(
    CourseNode elective,
    List<int> userEspecialidades,
  ) {
    if (!elective.isElective) return true;
    if (elective.specialties.isEmpty) return true;
    if (userEspecialidades.isEmpty) return true;
    final authService = AuthService.to;
    final userEspNames = userEspecialidades
        .map((id) => authService.getEspecialidadName(id))
        .where((name) => name.isNotEmpty)
        .map(normalizeSpecialty)
        .toSet();
    return elective.specialties.any(userEspNames.contains);
  }

  /// Lista filtrada: obligatorios siempre; electivos visibles si coinciden con
  /// la especialidad elegida O si el alumno ya los aprobó/está cursando
  /// (independientemente de la especialidad).
  List<CourseNode> visibleCoursesFor(UserModel user) {
    final progress = user.courseProgress ?? CourseProgress.empty();
    final approved = approvedCourseIdsFor(progress);
    final enrolled = progress.currentCourses;

    return _courses.where((c) {
      if (!c.isElective) return true;
      if (approved.contains(c.id) || enrolled.contains(c.id)) return true;
      return electiveMatchesUserSpecialties(c, user.especialidades);
    }).toList();
  }
}
