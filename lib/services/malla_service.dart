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

  static const Map<String, String> _especialidadAliases = {
    'Desarrollo de Software': 'Ingeniería de Software',
    'Ciberseguridad': 'Tecnologías de la Información',
    'Ciencia de Datos': 'Sistemas de Información',
    'TI': 'Tecnologías de la Información',
  };

  final RxList<CourseNode> _courses = <CourseNode>[].obs;
  final RxList<String> _specialties = <String>[].obs;

  List<CourseNode> get courses => _courses;
  List<String> get availableSpecialties => _specialties;

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

  int get maxRow {
    if (_courses.isEmpty) return 0;
    return _courses.map((c) => c.row).reduce((a, b) => a > b ? a : b);
  }

  String normalizeSpecialty(String esp) => _especialidadAliases[esp] ?? esp;

  Map<String, CourseStatus> computeStatuses(UserModel user) {
    final progress = user.courseProgress ?? CourseProgress.empty();

    final byId = <String, CourseNode>{for (final c in _courses) c.id: c};

    final approved = approvedCourseIdsFor(progress);

    final result = <String, CourseStatus>{};
    for (final c in _courses) {
      if (progress.currentCourses.contains(c.id)) {
        result[c.id] = CourseStatus.current;
        continue;
      }
      if (approved.contains(c.id)) {
        result[c.id] = CourseStatus.approved;
        continue;
      }

      final reqLvl = c.requiredCompletedLevel;
      if (reqLvl != null &&
          !hasCompletedMandatoryCyclesFromApprovedIds(approved, reqLvl)) {
        result[c.id] = CourseStatus.locked;
        continue;
      }

      final allPrereqsOk = c.coursePrerequisites.every((p) {
        if (!byId.containsKey(p)) return false;
        return approved.contains(p);
      });

      result[c.id] = allPrereqsOk ? CourseStatus.unlocked : CourseStatus.locked;
    }
    return result;
  }

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

  List<CourseNode> visibleCoursesFor(UserModel user) {
    return _courses
        .where((c) => electiveMatchesUserSpecialties(c, user.especialidades))
        .toList();
  }
}
