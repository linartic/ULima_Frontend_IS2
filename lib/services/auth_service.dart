// lib/services/auth_service.dart
// Autenticación real contra el backend + persistencia segura del JWT.

import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';
import 'api_client.dart';
import 'malla_service.dart';
import 'storage_service.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();
  static const String invalidCredentialsMessage =
      'Código o contraseña incorrectos.';

  final ApiClient _api = ApiClient();
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  final RxList<Map<String, dynamic>> _carreras = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _especialidades =
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
    return match != null ? match['name']?.toString() ?? '' : '';
  }

  String getEspecialidadName(int id) {
    final match = _especialidades.firstWhereOrNull((e) => e['id'] == id);
    return match != null ? match['name']?.toString() ?? '' : '';
  }

  Future<bool> tryRestoreSession() async {
    final token = await _storage.savedToken;
    if (token == null || token.isEmpty) return false;

    try {
      final response = await _api.getJson('/auth/me', token: token);
      final user = UserModel.fromJson(_mapFrom(response['user']));
      await _loadCatalogs(token: token, careerId: user.careerId);
      _currentUser.value = user;
      await _storage.saveCode(user.code);
      return true;
    } on ApiException {
      await _storage.clearSession();
      return false;
    } catch (_) {
      await _storage.clearSession();
      return false;
    }
  }

  Future<String?> login({
    required String code,
    required String password,
  }) async {
    _loading.value = true;
    try {
      final response = await _api.postJson(
        '/auth/login',
        body: {'code': code.trim(), 'password': password},
      );

      final token = response['token']?.toString();
      if (token == null || token.isEmpty) {
        return 'No se recibió token de sesión.';
      }

      final user = UserModel.fromJson(_mapFrom(response['user']));
      await _storage.saveToken(token);
      await _storage.saveCode(user.code);
      await _loadCatalogs(token: token, careerId: user.careerId);
      _currentUser.value = user;
      return null;
    } on ApiException catch (e) {
      if (e.code == 'USER_NOT_FOUND' || e.code == 'INVALID_PASSWORD') {
        return invalidCredentialsMessage;
      }
      if (e.code == 'NOT_ENROLLED') {
        return 'No tienes una matrícula activa.';
      }
      return e.message;
      return 'No se pudo conectar con el servidor.';
    } finally {
      _loading.value = false;
    }
  }

  Future<String?> loginWithGoogle() async {
    _loading.value = true;
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
      );
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) {
        return null; // El usuario canceló el popup
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null || idToken.isEmpty) {
        return 'No se obtuvo información de Google.';
      }

      final response = await _api.postJson(
        '/auth/google',
        body: {'idToken': idToken},
      );

      final token = response['token']?.toString();
      if (token == null || token.isEmpty) {
        return 'No se recibió token de sesión.';
      }

      final user = UserModel.fromJson(_mapFrom(response['user']));
      await _storage.saveToken(token);
      await _storage.saveCode(user.code);
      await _loadCatalogs(token: token, careerId: user.careerId);
      _currentUser.value = user;
      return null;
    } on ApiException catch (e) {
      if (e.code == 'INVALID_DOMAIN') {
        return 'Debes usar tu correo @aloe.ulima.edu.pe.';
      }
      if (e.code == 'USER_NOT_FOUND') {
        return 'Tu correo no está registrado en el sistema.';
      }
      return e.message;
    } catch (_) {
      return 'No se pudo iniciar sesión con Google.';
    } finally {
      _loading.value = false;
    }
  }

  Future<void> completeSetup({
    required int careerId,
    int? especialidadPrincipal,
    required List<int> especialidadesInteres,
  }) async {
    final user = _currentUser.value;
    if (user == null) return;

    final token = await _requiredToken();
    final response = await _api.putJson(
      '/academic-profile/me/specialties',
      token: token,
      body: {
        'primarySpecialtyId': especialidadPrincipal,
        'interestSpecialtyIds': especialidadesInteres,
      },
    );

    final savedSpecialties = _listFrom(response, 'specialties');
    final savedPrincipal = savedSpecialties
        .where((s) => s['selectionType']?.toString() == 'primary')
        .map((s) => _parseInt(s['specialtyId']))
        .whereType<int>()
        .firstOrNull;
    final savedInterest = savedSpecialties
        .where((s) => s['selectionType']?.toString() == 'interest')
        .map((s) => _parseInt(s['specialtyId']))
        .whereType<int>()
        .toList();

    user.careerId = careerId;
    user.especialidadPrincipal = savedPrincipal;
    user.especialidadesInteres = savedInterest;
    user.setupComplete = response['setupComplete'] as bool? ?? true;
    _currentUser.refresh();

    await _storage.saveSetup(
      code: user.code,
      careerId: careerId,
      especialidadPrincipal: user.especialidadPrincipal,
      especialidadesInteres: user.especialidadesInteres,
      setupComplete: user.setupComplete,
    );
  }

  Future<void> logout() async {
    final token = await _storage.savedToken;
    if (token != null && token.isNotEmpty) {
      try {
        await _api.postJson(
          '/auth/logout',
          token: token,
          body: const <String, dynamic>{},
        );
      } catch (_) {
        // Logout es stateless; si el servidor no responde, limpiamos local igual.
      }
    }
    MallaService.to.clear();
    _currentUser.value = null;
    await _storage.clearSession();
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
  }

  Future<void> _loadCatalogs({required String token, int? careerId}) async {
    final careersResponse = await _api.getJson(
      '/academic-profile/careers',
      token: token,
    );
    _carreras.assignAll(_listFrom(careersResponse, 'careers'));

    final specialtiesResponse = await _api.getJson(
      '/academic-profile/specialties',
      token: token,
      query: {'careerId': careerId?.toString()},
    );
    _especialidades.assignAll(_listFrom(specialtiesResponse, 'specialties'));
  }

  Future<String> _requiredToken() async {
    final token = await _storage.savedToken;
    if (token == null || token.isEmpty) {
      throw Exception('No hay sesión activa.');
    }
    return token;
  }

  Map<String, dynamic> _mapFrom(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _listFrom(
    Map<String, dynamic> response,
    String key,
  ) {
    final raw = response[key];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
