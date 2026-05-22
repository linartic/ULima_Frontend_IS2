// lib/pages/malla/malla_controller.dart
// Orquesta el estado de la malla: catálogo + estados por curso + zoom + dos piscinas.

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/malla_models.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/malla_service.dart';
import '../../services/storage_service.dart';

class MallaController extends GetxController {
  // ── Dimensiones del grid ────────────────────────────────────────────────────
  static const double cardWidth = 180;
  static const double cardHeight = 110;
  static const double columnGap = 40;
  static const double rowGap = 24;
  static const double padding = 24;
  static const double levelHeaderHeight = 32;
  static const double sectionLabelHeight = 36;
  // Espacio entre piscina obligatoria y piscina electiva (incluye el label).
  static const double sectionGap = 80;

  // ── Estado reactivo ─────────────────────────────────────────────────────────
  final loading = true.obs;
  final cards = <CourseNode>[].obs;
  final statuses = <String, CourseStatus>{}.obs;
  final zoom = 1.0.obs;

  // ── Caché de layout (se recalcula en _refresh) ──────────────────────────────
  final _electiveNormRows = <String, int>{};
  int _mandatoryMaxRow = 0;
  int _electiveMaxRow = 0;

  late final MallaService _malla;
  late final AuthService _auth;

  UserModel? get user => _auth.currentUser;

  // ── Piscinas ────────────────────────────────────────────────────────────────
  List<CourseNode> get mandatoryCards =>
      cards.where((c) => !c.isElective).toList();
  List<CourseNode> get electiveCards =>
      cards.where((c) => c.isElective).toList();

  // ── Geometría de secciones ──────────────────────────────────────────────────

  /// Y donde termina la piscina de obligatorios.
  double get _mandatorySectionBottom =>
      padding +
      sectionLabelHeight +
      levelHeaderHeight +
      (_mandatoryMaxRow + 1) * (cardHeight + rowGap);

  /// Y donde empiezan las cards de la piscina electiva.
  double get electiveSectionY => _mandatorySectionBottom + sectionGap;

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
      // Restaurar estados guardados en local storage.
      final saved = StorageService.to.savedStatuses;
      if (saved != null) {
        // Sólo aplicar los ids que siguen siendo visibles.
        final visible = cards.map((c) => c.id).toSet();
        final filtered = Map.fromEntries(
          saved.entries.where((e) => visible.contains(e.key)),
        );
        statuses.addAll(filtered);
        statuses.refresh();
      }
    } finally {
      loading.value = false;
    }
  }

  void _refresh() {
    final u = user;
    if (u == null) {
      cards.clear();
      statuses.clear();
      _electiveNormRows.clear();
      return;
    }
    final visible = _malla.visibleCoursesFor(u);
    cards.assignAll(visible);
    statuses.assignAll(_malla.computeStatuses(u));
    _computePoolLayout();
  }

  /// Calcula las filas normalizadas (0-indexed) de los electivos dentro de su
  /// piscina y el max row de cada sección.
  void _computePoolLayout() {
    final mandatory = mandatoryCards;
    _mandatoryMaxRow = mandatory.isEmpty
        ? 0
        : mandatory.map((c) => c.row).reduce(max);

    _electiveNormRows.clear();
    final byLevel = <int, List<CourseNode>>{};
    for (final c in electiveCards) {
      byLevel.putIfAbsent(c.level, () => []).add(c);
    }
    _electiveMaxRow = 0;
    for (final lvlCourses in byLevel.values) {
      lvlCourses.sort((a, b) => a.row.compareTo(b.row));
      for (int i = 0; i < lvlCourses.length; i++) {
        _electiveNormRows[lvlCourses[i].id] = i;
        if (i > _electiveMaxRow) _electiveMaxRow = i;
      }
    }
  }

  // ── Posicionamiento ─────────────────────────────────────────────────────────

  Offset positionFor(CourseNode c) {
    final x = padding + (c.level - 1) * (cardWidth + columnGap);
    if (!c.isElective) {
      return Offset(
        x,
        padding +
            sectionLabelHeight +
            levelHeaderHeight +
            c.row * (cardHeight + rowGap),
      );
    }
    final normRow = _electiveNormRows[c.id] ?? 0;
    return Offset(
      x,
      electiveSectionY + levelHeaderHeight + normRow * (cardHeight + rowGap),
    );
  }

  /// Y del separador entre piscinas (centro del sectionGap).
  double get separatorY => _mandatorySectionBottom + sectionGap / 2;

  Size canvasSize() {
    if (cards.isEmpty) return const Size(1200, 800);
    final maxLevel = cards.map((c) => c.level).reduce((a, b) => a > b ? a : b);
    final w = padding * 2 + maxLevel * (cardWidth + columnGap);
    final h = electiveCards.isEmpty
        ? _mandatorySectionBottom + padding
        : electiveSectionY +
              levelHeaderHeight +
              (_electiveMaxRow + 1) * (cardHeight + rowGap) +
              padding;
    return Size(w, h);
  }

  // ── Ciclo de estado ─────────────────────────────────────────────────────────

  void cycleStatus(String courseId) {
    final current = statuses[courseId] ?? CourseStatus.locked;
    if (current == CourseStatus.locked) return;
    CourseStatus next;
    switch (current) {
      case CourseStatus.unlocked:
        next = CourseStatus.current;
        break;
      case CourseStatus.current:
        next = CourseStatus.approved;
        break;
      case CourseStatus.approved:
        next = CourseStatus.unlocked;
        break;
      case CourseStatus.locked:
        return;
    }
    statuses[courseId] = next;
    statuses.refresh();
    StorageService.to.saveStatuses(statuses);
  }

  // ── Métricas de progreso ────────────────────────────────────────────────────
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

  // ── Zoom ────────────────────────────────────────────────────────────────────
  void zoomIn() => zoom.value = (zoom.value + 0.1).clamp(0.5, 1.6);
  void zoomOut() => zoom.value = (zoom.value - 0.1).clamp(0.5, 1.6);
  void resetZoom() => zoom.value = 1.0;
}
