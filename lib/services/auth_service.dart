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
  final RxList<Map<String, dynamic>> _carreras = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _especialidades = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _userEspecialidades = <Map<String, dynamic>>[].obs;
  final RxBool _loading = false.obs;

  UserModel? get currentUser => _currentUser.value;
  bool get isLoggedIn => _currentUser.value != null;
  bool get isLoading => _loading.value;

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

  /// Carga el catálogo de usuarios mock desde assets.
  /// Se llama automáticamente la primera vez que se intenta hacer login.
  Future<void> _ensureLoaded() async {
    if (_users.isNotEmpty) return;
    
    final raw = await rootBundle.loadString('assets/data/users.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = (decoded['users'] as List).cast<Map<String, dynamic>>();
    _users.assignAll(list);

    final rawCarreras = await rootBundle.loadString('assets/data/carreras.json');
    _carreras.assignAll((jsonDecode(rawCarreras) as List).cast<Map<String, dynamic>>());

    final rawEspecialidades = await rootBundle.loadString('assets/data/especialidades.json');
    _especialidades.assignAll((jsonDecode(rawEspecialidades) as List).cast<Map<String, dynamic>>());

    final rawUserEspecialidades = await rootBundle.loadString('assets/data/user_especialidades.json');
    _userEspecialidades.assignAll((jsonDecode(rawUserEspecialidades) as List).cast<Map<String, dynamic>>());
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

      final uJson = Map<String, dynamic>.from(match);
      final userCode = uJson['code'].toString();
      final userEspIds = _userEspecialidades
          .where((ue) => ue['user_code'].toString() == userCode)
          .map((ue) => ue['especialidad_id'] as int)
          .toList();
      uJson['especialidades'] = userEspIds;

      _currentUser.value = UserModel.fromJson(uJson);
      return null;
    } catch (e) {
      return 'Ocurrió un error inesperado: $e';
    } finally {
      _loading.value = false;
    }
  }

  /// Actualiza carrera/especialidades del usuario actual y marca el setup completo.
  void completeSetup({required int careerId, required List<int> especialidades}) {
    final u = _currentUser.value;
    if (u == null) return;
    u.careerId = careerId;
    u.especialidades = List.of(especialidades);
    u.setupComplete = true;
    _currentUser.refresh();
  }

  void logout() {
    _currentUser.value = null;
  }
}
