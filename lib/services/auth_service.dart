// lib/services/auth_service.dart
// Autenticación con JSON local + persistencia de sesión via StorageService.

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';

import '../models/user_model.dart';
import 'storage_service.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  final RxList<Map<String, dynamic>> _users = <Map<String, dynamic>>[].obs;
  final RxBool _loading = false.obs;

  UserModel? get currentUser => _currentUser.value;
  bool get isLoggedIn => _currentUser.value != null;
  bool get isLoading => _loading.value;

  StorageService get _storage => StorageService.to;

  /// Carga el catálogo de usuarios mock desde assets (idempotente).
  Future<void> _ensureLoaded() async {
    if (_users.isNotEmpty) return;
    final raw = await rootBundle.loadString('assets/data/users.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = (decoded['users'] as List).cast<Map<String, dynamic>>();
    _users.assignAll(list);
  }

  /// Intenta restaurar la sesión guardada en local storage.
  /// Devuelve true si se restauró correctamente.
  Future<bool> tryRestoreSession() async {
    final code = _storage.savedCode;
    if (code == null) return false;
    await _ensureLoaded();
    final match = _users.firstWhereOrNull(
      (u) => u['code'].toString() == code,
    );
    if (match == null) {
      await _storage.clearSession();
      return false;
    }
    final user = UserModel.fromJson(match);
    // Aplicar datos de setup guardados.
    final career = _storage.savedCareer;
    if (career != null && career.isNotEmpty) user.career = career;
    final especialidades = _storage.savedEspecialidades;
    if (especialidades.isNotEmpty) user.especialidades = especialidades;
    user.setupComplete = _storage.savedSetupComplete;

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
      if (match == null) return 'No encontramos un alumno con ese código.';
      if ((match['password'] as String?) != password) {
        return 'La contraseña no es correcta.';
      }
      _currentUser.value = UserModel.fromJson(match);
      await _storage.saveCode(normalizedCode);
      return null;
    } catch (e) {
      return 'Ocurrió un error inesperado: $e';
    } finally {
      _loading.value = false;
    }
  }

  /// Actualiza carrera/especialidades y marca el setup completo.
  Future<void> completeSetup({
    required String career,
    required List<String> especialidades,
  }) async {
    final u = _currentUser.value;
    if (u == null) return;
    u.career = career;
    u.especialidades = List.of(especialidades);
    u.setupComplete = true;
    _currentUser.refresh();
    await _storage.saveSetup(
      career: career,
      especialidades: especialidades,
      setupComplete: true,
    );
  }

  Future<void> logout() async {
    _currentUser.value = null;
    await _storage.clearSession();
  }
}
