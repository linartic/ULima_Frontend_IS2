// lib/services/auth_service.dart
// Servicio de autenticación basado en JSON local (assets/data/users.json).
// Mantiene la sesión en memoria mientras la app corre.

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';

import '../models/user_model.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  final RxList<Map<String, dynamic>> _users = <Map<String, dynamic>>[].obs;
  final RxBool _loading = false.obs;

  UserModel? get currentUser => _currentUser.value;
  bool get isLoggedIn => _currentUser.value != null;
  bool get isLoading => _loading.value;

  /// Carga el catálogo de usuarios mock desde assets.
  /// Se llama automáticamente la primera vez que se intenta hacer login.
  Future<void> _ensureLoaded() async {
    if (_users.isNotEmpty) return;
    final raw = await rootBundle.loadString('assets/data/users.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = (decoded['users'] as List).cast<Map<String, dynamic>>();
    _users.assignAll(list);
  }

  /// Intenta autenticar al usuario. Devuelve `null` si las credenciales
  /// son correctas, o un mensaje de error legible si fallan.
  Future<String?> login({required String code, required String password}) async {
    _loading.value = true;
    try {
      await _ensureLoaded();
      final normalizedCode = code.trim();
      final match = _users.firstWhereOrNull(
        (u) => u['code'].toString() == normalizedCode,
      );
      if (match == null) {
        return 'No encontramos un alumno con ese código.';
      }
      if ((match['password'] as String?) != password) {
        return 'La contraseña no es correcta.';
      }
      _currentUser.value = UserModel.fromJson(match);
      return null;
    } catch (e) {
      return 'Ocurrió un error inesperado: $e';
    } finally {
      _loading.value = false;
    }
  }

  /// Actualiza carrera/especialidades del usuario actual y marca el setup completo.
  void completeSetup({required String career, required List<String> especialidades}) {
    final u = _currentUser.value;
    if (u == null) return;
    u.career = career;
    u.especialidades = List.of(especialidades);
    u.setupComplete = true;
    _currentUser.refresh();
  }

  void logout() {
    _currentUser.value = null;
  }
}
