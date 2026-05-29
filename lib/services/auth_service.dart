// lib/services/auth_service.dart
// Autenticación contra backend + persistencia de sesión via StorageService.

import 'package:get/get.dart';

import '../models/user_model.dart';
import 'api_client.dart';
import 'storage_service.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();
  static const String invalidCredentialsMessage =
      'Código o contraseña incorrectos.';

  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  final RxList<Map<String, dynamic>> _carreras = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _especialidades =
      <Map<String, dynamic>>[].obs;
  final RxBool _loading = false.obs;
  final ApiClient _api = ApiClient();

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

  Future<void> loadCatalogs() async {
    final careersResponse = await _api.getJson('/academic-profile/careers');
    _carreras.assignAll(
      (careersResponse['careers'] as List? ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
    );

    final specialtiesResponse = await _api.getJson(
      '/academic-profile/specialties',
    );
    _especialidades.assignAll(
      (specialtiesResponse['specialties'] as List? ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
    );
  }

  /// Intenta restaurar la sesión guardada en local storage.
  /// Devuelve true si se restauró correctamente.
  Future<bool> tryRestoreSession() async {
    final code = _storage.savedCode;
    if (code == null) return false;
    try {
      final response = await _api.getJson('/auth/me?code=$code');
      final user = UserModel.fromJson(
        Map<String, dynamic>.from(response['user'] as Map),
      );
      await loadCatalogs();
      await _applyStoredSetup(user);
      _currentUser.value = user;
      return true;
    } catch (_) {
      await _storage.clearSession();
      return false;
    }
  }

  /// Intenta autenticar al usuario. Devuelve null si OK, o mensaje de error.
  Future<String?> login({
    required String code,
    required String password,
  }) async {
    _loading.value = true;
    try {
      final normalizedCode = code.trim();
      final response = await _api.postJson(
        '/auth/login',
        {'code': normalizedCode, 'password': password},
      );
      final user = UserModel.fromJson(
        Map<String, dynamic>.from(response['user'] as Map),
      );
      await loadCatalogs();
      await _applyStoredSetup(user);
      _currentUser.value = user;
      await _storage.saveCode(normalizedCode);
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
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

    try {
      await _api.putJson('/academic-profile/me/specialties', {
        'primarySpecialtyId': especialidadPrincipal,
        'interestSpecialtyIds': especialidadesInteres,
      });
    } catch (e) {
      print("Error guardando especialidades en servidor: $e");
    }

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
