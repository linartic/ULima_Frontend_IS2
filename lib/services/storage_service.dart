// lib/services/storage_service.dart
// Persistencia simple de sesión via SharedPreferences (localStorage en web).

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/malla_models.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find();

  late SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const _kToken = 'session_token';
  static const _kCode = 'session_code';
  static const _kCareerId = 'session_career_id';
  static const _kLegacyCareer = 'session_career';
  static const _kEspecialidades = 'session_especialidades_v2';
  static const _kLegacyEspecialidades = 'session_especialidades';
  static const _kPrincipal = 'session_especialidad_principal';
  static const _kInteres = 'session_especialidades_interes';
  static const _kSetupComplete = 'session_setup_complete';
  static const _kStatuses = 'session_statuses_v2';
  static const _kLegacyStatuses = 'session_statuses';
  static const _kUserSetups = 'user_setups_v1';
  static const _kUserStatuses = 'user_statuses_v1';

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // ── Sesión (código del alumno) ──────────────────────────────────────────────

  Future<String?> get savedToken => _secureStorage.read(key: _kToken);

  Future<void> saveToken(String token) =>
      _secureStorage.write(key: _kToken, value: token);

  Future<void> clearToken() => _secureStorage.delete(key: _kToken);

  String? get savedCode => _prefs.getString(_kCode);

  Future<void> saveCode(String code) => _prefs.setString(_kCode, code);

  // ── Setup de carrera/especialidad ───────────────────────────────────────────

  int? get savedCareerId => _prefs.getInt(_kCareerId);

  int? get savedEspecialidadPrincipal =>
      _prefs.containsKey(_kPrincipal) ? _prefs.getInt(_kPrincipal) : null;

  List<int> get savedEspecialidadesInteres =>
      _parseIntList(_prefs.getString(_kInteres));

  /// Lectura legacy (lista plana anterior). Usado para migrar sesiones antiguas.
  List<int> get savedEspecialidades =>
      _parseIntList(_prefs.getString(_kEspecialidades));

  List<int> _parseIntList(String? raw) {
    if (raw == null) return const [];
    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((v) {
          if (v is int) return v;
          if (v is num) return v.toInt();
          return int.tryParse(v.toString());
        })
        .whereType<int>()
        .toList();
  }

  bool get hasSavedSetup =>
      _prefs.containsKey(_kCareerId) ||
      _prefs.containsKey(_kLegacyCareer) ||
      _prefs.containsKey(_kEspecialidades) ||
      _prefs.containsKey(_kLegacyEspecialidades) ||
      _prefs.containsKey(_kPrincipal) ||
      _prefs.containsKey(_kInteres) ||
      _prefs.containsKey(_kSetupComplete);

  bool get savedSetupComplete => _prefs.getBool(_kSetupComplete) ?? false;

  Map<String, dynamic> _savedUserSetups() {
    final raw = _prefs.getString(_kUserSetups);
    if (raw == null) return <String, dynamic>{};
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return <String, dynamic>{};
    return Map<String, dynamic>.from(decoded);
  }

  Map<String, dynamic>? savedSetupFor(String code) {
    final setup = _savedUserSetups()[code.trim()];
    if (setup is! Map) return null;
    return Map<String, dynamic>.from(setup);
  }

  bool hasSavedSetupFor(String code) => savedSetupFor(code) != null;

  int? savedCareerIdFor(String code) {
    final setup = savedSetupFor(code);
    return _parseInt(setup?['career_id']);
  }

  int? savedEspecialidadPrincipalFor(String code) {
    final setup = savedSetupFor(code);
    return _parseInt(setup?['especialidad_principal']);
  }

  List<int> savedEspecialidadesInteresFor(String code) {
    final setup = savedSetupFor(code);
    return _parseDynamicIntList(setup?['especialidades_interes']);
  }

  List<int> savedEspecialidadesFor(String code) {
    final setup = savedSetupFor(code);
    return _parseDynamicIntList(setup?['especialidades']);
  }

  bool savedSetupCompleteFor(String code) {
    final setup = savedSetupFor(code);
    return setup?['setupComplete'] as bool? ?? false;
  }

  Future<void> saveSetup({
    required String code,
    required int careerId,
    int? especialidadPrincipal,
    required List<int> especialidadesInteres,
    required bool setupComplete,
  }) async {
    await _prefs.setInt(_kCareerId, careerId);
    if (especialidadPrincipal != null) {
      await _prefs.setInt(_kPrincipal, especialidadPrincipal);
    } else {
      await _prefs.remove(_kPrincipal);
    }
    await _prefs.setString(_kInteres, jsonEncode(especialidadesInteres));
    // Mantiene la clave legacy con la lista combinada para compatibilidad.
    final combined = [?especialidadPrincipal, ...especialidadesInteres];
    await _prefs.setString(_kEspecialidades, jsonEncode(combined));
    await _prefs.setBool(_kSetupComplete, setupComplete);

    final setups = _savedUserSetups();
    setups[code.trim()] = {
      'career_id': careerId,
      'especialidad_principal': especialidadPrincipal,
      'especialidades_interes': especialidadesInteres,
      'especialidades': combined,
      'setupComplete': setupComplete,
    };
    await _prefs.setString(_kUserSetups, jsonEncode(setups));
  }

  // ── Estados de la malla ─────────────────────────────────────────────────────

  /// Guarda el mapa { courseId → status.index }.
  Future<void> saveStatuses(
    Map<String, CourseStatus> statuses, {
    String? code,
  }) async {
    final map = {for (final e in statuses.entries) e.key: e.value.index};
    await _prefs.setString(_kStatuses, jsonEncode(map));
    final normalizedCode = code?.trim();
    if (normalizedCode == null || normalizedCode.isEmpty) return;

    final userStatuses = _savedUserStatuses();
    userStatuses[normalizedCode] = map;
    await _prefs.setString(_kUserStatuses, jsonEncode(userStatuses));
  }

  /// Restaura el mapa. Devuelve null si no hay datos guardados.
  Map<String, CourseStatus>? get savedStatuses {
    final raw = _prefs.getString(_kStatuses);
    if (raw == null) return null;
    return _parseStatusesMap(jsonDecode(raw));
  }

  Map<String, CourseStatus>? savedStatusesFor(String code) {
    final statuses = _savedUserStatuses()[code.trim()];
    if (statuses is! Map) return null;
    return _parseStatusesMap(statuses);
  }

  Map<String, dynamic> _savedUserStatuses() {
    final raw = _prefs.getString(_kUserStatuses);
    if (raw == null) return <String, dynamic>{};
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return <String, dynamic>{};
    return Map<String, dynamic>.from(decoded);
  }

  Map<String, CourseStatus> _parseStatusesMap(dynamic value) {
    final map = Map<String, dynamic>.from(value as Map);
    return {
      for (final e in map.entries)
        e.key: CourseStatus.values[(e.value as num).toInt()],
    };
  }

  // ── Limpieza ────────────────────────────────────────────────────────────────

  Future<void> clearSession() async {
    await clearToken();
    await _prefs.remove(_kCode);
    await _prefs.remove(_kCareerId);
    await _prefs.remove(_kLegacyCareer);
    await _prefs.remove(_kEspecialidades);
    await _prefs.remove(_kLegacyEspecialidades);
    await _prefs.remove(_kPrincipal);
    await _prefs.remove(_kInteres);
    await _prefs.remove(_kSetupComplete);
    await _prefs.remove(_kStatuses);
    await _prefs.remove(_kLegacyStatuses);
  }

  int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  List<int> _parseDynamicIntList(dynamic value) {
    if (value is String) return _parseIntList(value);
    if (value is! List) return const [];
    return value
        .map((v) {
          if (v is int) return v;
          if (v is num) return v.toInt();
          return int.tryParse(v.toString());
        })
        .whereType<int>()
        .toList();
  }
}
