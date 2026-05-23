// lib/services/storage_service.dart
// Persistencia simple de sesión via SharedPreferences (localStorage en web).

import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/malla_models.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find();

  late SharedPreferences _prefs;

  static const _kCode = 'session_code';
  static const _kCareerId = 'session_career_id';
  static const _kLegacyCareer = 'session_career';
  static const _kEspecialidades = 'session_especialidades_v2';
  static const _kLegacyEspecialidades = 'session_especialidades';
  static const _kSetupComplete = 'session_setup_complete';
  static const _kStatuses = 'session_statuses_v2';
  static const _kLegacyStatuses = 'session_statuses';

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // ── Sesión (código del alumno) ──────────────────────────────────────────────

  String? get savedCode => _prefs.getString(_kCode);

  Future<void> saveCode(String code) => _prefs.setString(_kCode, code);

  // ── Setup de carrera/especialidad ───────────────────────────────────────────

  int? get savedCareerId => _prefs.getInt(_kCareerId);

  List<int> get savedEspecialidades {
    final raw = _prefs.getString(_kEspecialidades);
    if (raw == null) return const [];
    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((value) {
          if (value is int) return value;
          if (value is num) return value.toInt();
          return int.tryParse(value.toString());
        })
        .whereType<int>()
        .toList();
  }

  bool get hasSavedSetup =>
      _prefs.containsKey(_kCareerId) ||
      _prefs.containsKey(_kLegacyCareer) ||
      _prefs.containsKey(_kEspecialidades) ||
      _prefs.containsKey(_kLegacyEspecialidades) ||
      _prefs.containsKey(_kSetupComplete);

  bool get savedSetupComplete => _prefs.getBool(_kSetupComplete) ?? false;

  Future<void> saveSetup({
    required int careerId,
    required List<int> especialidades,
    required bool setupComplete,
  }) async {
    await _prefs.setInt(_kCareerId, careerId);
    await _prefs.setString(_kEspecialidades, jsonEncode(especialidades));
    await _prefs.setBool(_kSetupComplete, setupComplete);
  }

  // ── Estados de la malla ─────────────────────────────────────────────────────

  /// Guarda el mapa { courseId → status.index }.
  Future<void> saveStatuses(Map<String, CourseStatus> statuses) {
    final map = {for (final e in statuses.entries) e.key: e.value.index};
    return _prefs.setString(_kStatuses, jsonEncode(map));
  }

  /// Restaura el mapa. Devuelve null si no hay datos guardados.
  Map<String, CourseStatus>? get savedStatuses {
    final raw = _prefs.getString(_kStatuses);
    if (raw == null) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return {
      for (final e in map.entries)
        e.key: CourseStatus.values[(e.value as num).toInt()],
    };
  }

  // ── Limpieza ────────────────────────────────────────────────────────────────

  Future<void> clearSession() async {
    await _prefs.remove(_kCode);
    await _prefs.remove(_kCareerId);
    await _prefs.remove(_kLegacyCareer);
    await _prefs.remove(_kEspecialidades);
    await _prefs.remove(_kLegacyEspecialidades);
    await _prefs.remove(_kSetupComplete);
    await _prefs.remove(_kStatuses);
    await _prefs.remove(_kLegacyStatuses);
  }
}
