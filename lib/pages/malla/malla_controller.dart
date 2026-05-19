// lib/pages/malla/malla_controller.dart
// Orquesta el estado de la malla: catálogo + estados por curso + zoom.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/malla_models.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/malla_service.dart';

class MallaController extends GetxController {
  // --- Dimensiones del grid (deben coincidir con malla_page.dart) ---
  static const double cardWidth = 180;
  static const double cardHeight = 110;
  static const double columnGap = 40;
  static const double rowGap = 24;
  static const double padding = 24;

  // --- Estado reactivo ---
  final loading = true.obs;
  final cards = <CourseNode>[].obs;
  final statuses = <String, CourseStatus>{}.obs;
  final zoom = 1.0.obs;

  // Filtro de visibilidad por categoría (UX adicional)
  final showElectives = true.obs;

  late final MallaService _malla;
  late final AuthService _auth;

  UserModel? get user => _auth.currentUser;

  @override
  void onInit() {
    super.onInit();
    _malla = MallaService.to;
    _auth = AuthService.to;
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    loading.value = true;
    try {
      await _malla.load();
      _refresh();
    } finally {
      loading.value = false;
    }
  }

  /// Re-calcula la lista visible y los estados para el alumno actual.
  void _refresh() {
    final u = user;
    if (u == null) {
      cards.clear();
      statuses.clear();
      return;
    }
    final visible = _malla.visibleCoursesFor(u);
    cards.assignAll(visible);
    statuses.assignAll(_malla.computeStatuses(u));
  }

  /// Cicla el estado de un curso al hacer tap (locked queda fuera del ciclo).
  void cycleStatus(String courseId) {
    final current = statuses[courseId] ?? CourseStatus.locked;
    CourseStatus next;
    switch (current) {
      case CourseStatus.locked:
        // No se puede cambiar lo bloqueado.
        return;
      case CourseStatus.unlocked:
        next = CourseStatus.current;
        break;
      case CourseStatus.current:
        next = CourseStatus.approved;
        break;
      case CourseStatus.approved:
        next = CourseStatus.unlocked;
        break;
    }
    statuses[courseId] = next;
    statuses.refresh();
  }

  /// Posición (top-left) del card según nivel/row, ya escalado por zoom.
  Offset positionFor(CourseNode c) {
    final x = padding + (c.level - 1) * (cardWidth + columnGap);
    final y = padding + c.row * (cardHeight + rowGap);
    return Offset(x, y);
  }

  /// Tamaño total del lienzo (sin zoom).
  Size canvasSize() {
    int maxLevel = 0;
    int maxRow = 0;
    for (final c in cards) {
      if (c.level > maxLevel) maxLevel = c.level;
      if (c.row > maxRow) maxRow = c.row;
    }
    final w = padding * 2 + maxLevel * (cardWidth + columnGap);
    final h = padding * 2 + (maxRow + 1) * (cardHeight + rowGap);
    return Size(w, h);
  }

  // ---- Métricas de progreso para la barra superior ----
  int get approvedCount =>
      statuses.values.where((s) => s == CourseStatus.approved).length;
  int get currentCount =>
      statuses.values.where((s) => s == CourseStatus.current).length;
  int get unlockedCount =>
      statuses.values.where((s) => s == CourseStatus.unlocked).length;
  int get totalVisible => cards.length;

  double get approvedRatio =>
      totalVisible == 0 ? 0 : approvedCount / totalVisible;

  bool hasCompletedMandatoryCycles(
    int throughLevel,
    Map<String, CourseStatus> sourceStatuses,
  ) {
    return _malla.hasCompletedMandatoryCyclesFromStatuses(
      sourceStatuses,
      throughLevel,
    );
  }

  // ---- Zoom controls ----
  void zoomIn() => zoom.value = (zoom.value + 0.1).clamp(0.5, 1.6);
  void zoomOut() => zoom.value = (zoom.value - 0.1).clamp(0.5, 1.6);
  void resetZoom() => zoom.value = 1.0;
}
