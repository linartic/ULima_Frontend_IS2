// lib/services/auth_service.dart
// Autenticación con JSON local + persistencia de sesión via StorageService.

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';

import '../models/user_model.dart';
import 'storage_service.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();
  static const String invalidCredentialsMessage =
      'Código o contraseña incorrectos.';

  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  final RxList<Map<String, dynamic>> _users = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _carreras = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _especialidades =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _userEspecialidades =
      <Map<String, dynamic>>[].obs;
  final RxBool _loading = false.obs;

  UserModel? get currentUser => _currentUser.value;
  Rx<UserModel?> get currentUserRx => _currentUser;
  bool get isLoggedIn => _currentUser.value != null;
  bool get isLoading => _loading.value;

  StorageService get _storage => StorageService.to;

  List<Map<String, dynamic>> get carreras => _carreras;
  List<Map<String, dynamic>> get especialidades => _especialidades;

  String getCareerName(int? id) {
    if (id == null) return '';
    final match = _carreras.firstWhereOrNull((c) => c['id'] == id);
    return match != null ? match['name'] as String : '';
  }

  String getEspecialidadName(int id) {
    final match = _especialidades.firstWhereOrNull((e) => e['id'] == id);
    return match != null ? match['name'] as String : '';
  }

  /// Carga el catálogo de usuarios mock desde assets (idempotente).
  Future<void> _ensureLoaded() async {
    if (_users.isNotEmpty &&
        _carreras.isNotEmpty &&
        _especialidades.isNotEmpty &&
        _userEspecialidades.isNotEmpty) {
      return;
    }

    final raw = await rootBundle.loadString('assets/data/users.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = (decoded['users'] as List).cast<Map<String, dynamic>>();
    _users.assignAll(list);

    final rawCarreras = await rootBundle.loadString(
      'assets/data/carreras.json',
    );
    _carreras.assignAll(
      (jsonDecode(rawCarreras) as List).cast<Map<String, dynamic>>(),
    );

    final rawEspecialidades = await rootBundle.loadString(
      'assets/data/especialidades.json',
    );
    _especialidades.assignAll(
      (jsonDecode(rawEspecialidades) as List).cast<Map<String, dynamic>>(),
    );

    final rawUserEspecialidades = await rootBundle.loadString(
      'assets/data/user_especialidades.json',
    );
    _userEspecialidades.assignAll(
      (jsonDecode(rawUserEspecialidades) as List).cast<Map<String, dynamic>>(),
    );
  }

  Map<String, dynamic> _withEspecialidadesFromRelation(
    Map<String, dynamic> userJson,
  ) {
    final copy = Map<String, dynamic>.from(userJson);
    final userCode = copy['code'].toString();
    final userEspIds = _userEspecialidades
        .where((ue) => ue['user_code'].toString() == userCode)
        .map((ue) => (ue['especialidad_id'] as num).toInt())
        .toList();

    if (userEspIds.isNotEmpty) {
      copy['especialidades'] = userEspIds;
    }
    return copy;
  }

  /// Intenta restaurar la sesión guardada en local storage.
  /// Devuelve true si se restauró correctamente.
  Future<bool> tryRestoreSession() async {
    final code = _storage.savedCode;
    if (code == null) return false;
    await _ensureLoaded();
    final match = _users.firstWhereOrNull((u) => u['code'].toString() == code);
    if (match == null) {
      await _storage.clearSession();
      return false;
    }
    final user = UserModel.fromJson(_withEspecialidadesFromRelation(match));
    await _applyStoredSetup(user);

    _currentUser.value = user;
    return true;
  }

  /// Intenta autenticar al usuario. Devuelve null si OK, o mensaje de error.
  Future<String?> login({
    required String code,
    required String password,
  }) async {
    _loading.value = true;
    try {
      await _ensureLoaded();
      final normalizedCode = code.trim();
      final match = _users.firstWhereOrNull(
        (u) => u['code'].toString() == normalizedCode,
      );
      final passwordMatches =
          match != null && (match['password'] as String?) == password;
      if (!passwordMatches) return invalidCredentialsMessage;

      final user = UserModel.fromJson(_withEspecialidadesFromRelation(match));
      await _applyStoredSetup(user);
      _currentUser.value = user;
      await _storage.saveCode(normalizedCode);
      return null;
    } catch (e) {
      return 'Ocurrió un error inesperado: $e';
    } finally {
      _loading.value = false;
    }
  }

  /// Actualiza carrera/especialidades del usuario actual y marca el setup completo.
  Future<void> completeSetup({
    required int careerId,
    int? especialidadPrincipal,
    required List<int> especialidadesInteres,
  }) async {
    final u = _currentUser.value;
    if (u == null) return;
    u.careerId = careerId;
    u.especialidadPrincipal = especialidadPrincipal;
    u.especialidadesInteres = List.of(especialidadesInteres);
    u.setupComplete = true;
    _currentUser.refresh();
    await _storage.saveSetup(
      code: u.code,
      careerId: careerId,
      especialidadPrincipal: especialidadPrincipal,
      especialidadesInteres: especialidadesInteres,
      setupComplete: true,
    );
  }

  Future<void> logout() async {
    _currentUser.value = null;
    await _storage.clearSession();
  }

  Future<void> _applyStoredSetup(UserModel user) async {
    final code = user.code;
    final hasUserSetup = _storage.hasSavedSetupFor(code);
    if (!hasUserSetup && !_storage.hasSavedSetup) return;

    final careerId = hasUserSetup
        ? _storage.savedCareerIdFor(code)
        : _storage.savedCareerId;
    if (careerId != null) user.careerId = careerId;

    user.setupComplete = hasUserSetup
        ? _storage.savedSetupCompleteFor(code)
        : _storage.savedSetupComplete;

    final principal = hasUserSetup
        ? _storage.savedEspecialidadPrincipalFor(code)
        : _storage.savedEspecialidadPrincipal;
    final interes = hasUserSetup
        ? _storage.savedEspecialidadesInteresFor(code)
        : _storage.savedEspecialidadesInteres;

    if (principal != null || interes.isNotEmpty) {
      user.especialidadPrincipal = principal;
      user.especialidadesInteres = interes;
    } else {
      final legacy = hasUserSetup
          ? _storage.savedEspecialidadesFor(code)
          : _storage.savedEspecialidades;
      if (legacy.isNotEmpty) user.especialidadesInteres = legacy;
    }

    if (!hasUserSetup && user.careerId != null) {
      await _storage.saveSetup(
        code: code,
        careerId: user.careerId!,
        especialidadPrincipal: user.especialidadPrincipal,
        especialidadesInteres: user.especialidadesInteres,
        setupComplete: user.setupComplete,
      );
    }
  }
}
