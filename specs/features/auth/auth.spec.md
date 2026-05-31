---
name: Auth
description: Login, logout, JWT session persistence, and authenticated navigation for ULima++ Flutter app
targets:
  - ../../../lib/pages/login/**
  - ../../../lib/services/auth_service.dart
  - ../../../lib/services/storage_service.dart
  - ../../../lib/services/api_client.dart
  - ../../../lib/models/user_model.dart
---

# Auth

## User Stories

| ID | Description |
| --- | --- |
| US01 | Iniciar sesión con código y contraseña. |
| US02 | Cerrar sesión. |

## Business Rules

### BR-AUTH-F-01: Login flow
- El formulario recolecta `code` y `password`.
- `LoginController.submit()` valida que ambos campos no estén vacíos.
- Si vacío → muestra `"Ingresa tu código y contraseña."` sin llamar API.
- Si completo → llama `AuthService.login(code, password)`.
- El servicio envía `POST /auth/login` con `{ code, password }`.
- Si la respuesta es exitosa:
  1. Guarda el JWT (`token`) en `StorageService`.
  2. Construye `UserModel` desde `user`.
  3. Redirige a `/home` si `user.setupComplete`, o a `/setup-carrera` si no.
- Si la respuesta es error (`401 USER_NOT_FOUND`, `401 INVALID_PASSWORD`, etc.):
  - Muestra `"Código o contraseña incorrectos."` sin exponer detalles del backend.

### BR-AUTH-F-02: JWT token storage
- El JWT recibido en el login se persiste en `shared_preferences` bajo la clave `session_token`.
- No se persiste el `code` del usuario; el JWT es suficiente para identificar la sesión.
- El token se usa como `Authorization: Bearer <token>` en todas las requests autenticadas.

### BR-AUTH-F-03: Session restoration
- Al iniciar la app, `main.dart` llama `AuthService.tryRestoreSession()`.
- Si hay un JWT guardado:
  1. Configura el token en `ApiClient` para requests autenticados.
  2. Llama `GET /auth/me` (con el Bearer token) para validar la sesión y obtener datos del usuario.
  3. Si la respuesta es exitosa → construye `UserModel` y navega según `setupComplete`.
  4. Si la respuesta es error (`401 INVALID_TOKEN`) → limpia la sesión y redirige a `/login`.
- Si no hay JWT guardado → redirige a `/login`.

### BR-AUTH-F-04: Logout
- `AuthService.logout()`:
  1. Envía `POST /auth/logout` con el Bearer token (best-effort, no bloquea).
  2. Limpia el JWT y datos de sesión de `StorageService`.
  3. Redirige a `/login`.
- El cierre de sesión es definitivo: no hay re-autenticación automática.

### BR-AUTH-F-05: Role mapping
- El backend devuelve `role` como `"student"`, `"delegate"` o `"subdelegate"`.
- `UserModel.role` almacena el valor en español: `"estudiante"`, `"delegado"`, `"subdelegado"`.
- Mapeo:
  - `"student"` → `"estudiante"`
  - `"delegate"` → `"delegado"`
  - `"subdelegate"` → `"subdelegado"`
- `UserModel.isDelegate` retorna `true` si role es `"delegado"` o `"subdelegado"`.

### BR-AUTH-F-06: UserModel from backend DTO
- El backend devuelve `User` con esta estructura:

```json
{
  "id": 1,
  "studentId": 10,
  "code": "20201234",
  "fullName": "Nombre Apellido",
  "institutionalEmail": "user@aloe.ulima.edu.pe",
  "role": "student",
  "careerId": 1,
  "curriculumId": 1,
  "currentLevel": 5
}
```

- `UserModel.fromJson` debe mapear:
  | Backend field | UserModel field | Transformación |
  |---|---| --- |
  | `code` | `code` | directo |
  | `fullName` | `firstName`, `lastName` | split por último espacio: "Nombre Apellido" → firstName="Nombre", lastName="Apellido" |
  | `institutionalEmail` | `email` | directo |
  | `role` | `role` | mapear a español |
  | `careerId` | `careerId` | directo |
  | `currentCycle` | `currentCycle` | no viene del backend; se mantiene como "2026-1" por defecto |
  | `setupComplete` | `setupComplete` | no viene del backend; se lee desde `StorageService` |
  | `especialidadPrincipal` | `especialidadPrincipal` | no viene del backend; se lee desde `StorageService` |
  | `especialidadesInteres` | `especialidadesInteres` | no viene del backend; se lee desde `StorageService` |

### BR-AUTH-F-07: ApiClient auth header
- `ApiClient` debe exponer un método o setter para configurar el token JWT.
- Todas las requests que no sean `POST /auth/login` deben incluir `Authorization: Bearer <token>`.
- Si una request autenticada recibe un error `401 Unauthorized`, el Frontend debe interceptarlo globalmente, limpiar los datos locales (`StorageService.clearSession()`) y redirigir forzosamente a `/login` (previniendo un estado inválido por sesiones concurrentes en otros dispositivos).

### BR-AUTH-F-08: Loading state
- Durante el login, el botón "Entrar" muestra un `CircularProgressIndicator` y está deshabilitado.
- Esto ya está implementado en `login_page.dart` vía `controller.submitting.value`.

### BR-AUTH-F-09: Single Active Session (Concurrency)
- El sistema **no permite sesiones concurrentes** para evitar incongruencias de datos (ej. un usuario modificando su perfil desde celular y web simultáneamente).
- El Backend implementará "Token Versioning" u otro mecanismo para asegurar que al generar un nuevo JWT por un Login, los tokens anteriores del mismo usuario queden invalidados.
- Si un usuario inicia sesión en un dispositivo nuevo, el dispositivo antiguo recibirá un error HTTP `401`. Esto desencadenará el flujo descrito en la regla BR-AUTH-F-07, expulsando al usuario del dispositivo antiguo de forma segura.

## UI Behavior

### Login screen (`login_page.dart`)
- La UI ya está implementada y no requiere cambios visuales.
- **Estados**:
  - **Initial**: campos vacíos, botón "Entrar" habilitado.
  - **Loading**: botón muestra spinner y está deshabilitado.
  - **Error**: mensaje de error en rojo debajo del campo de contraseña.
  - **Success**: navega a `/home` o `/setup-carrera` según `setupComplete`.
- **Validación local**: si code o password están vacíos → `"Ingresa tu código y contraseña."`.

### Navigation
- `POST /auth/login` exitoso → `Get.offAllNamed('/home')` si `setupComplete` es `true`, o `Get.offAllNamed('/setup-carrera')` si es `false`.
- `POST /auth/logout` → `Get.offAllNamed('/login')`.
- Session restoration fallida → `Get.offAllNamed('/login')`.

## Data Flow

### Login flow
```
User input → LoginController.submit()
  → AuthService.login(code, password)
    → ApiClient.postJson('/auth/login', { code, password })
    → Response: { token, user }
    → StorageService.saveToken(token)
    → UserModel.fromJson(user)
    → StorageService.loadSetup(code) → setupComplete, especialidades
    → AuthService.currentUser = user
  → LoginController: Get.offAllNamed(route)
```

### Session restoration flow
```
App start → main.dart → AuthService.tryRestoreSession()
  → StorageService.getToken() ? null → return false → navigate /login
  → ApiClient.setToken(token)
  → ApiClient.getJson('/auth/me')
    → Response: { user }
    → UserModel.fromJson(user)
    → StorageService.loadSetup(code) → setupComplete, especialidades
    → AuthService.currentUser = user
    → return true → navigate según setupComplete
```

### Logout flow
```
User action → AuthService.logout()
  → ApiClient.postJson('/auth/logout') (best-effort)
  → StorageService.clearSession() (incluye token)
  → AuthService.currentUser = null
  → Get.offAllNamed('/login')
```

## Implementation Plan

### `api_client.dart`
- Agregar propiedad `String? _authToken`.
- Agregar método `setToken(String? token)` para configurar el token.
- Modificar `getJson` y `postJson` para incluir `Authorization: Bearer <token>` cuando `_authToken` no sea null, excepto para `POST /auth/login`.
- Opcional: detectar `401` en `_decode` y lanzar un error específico.

### `storage_service.dart`
- Agregar constantes:
  ```dart
  static const _kToken = 'session_token';
  ```
- Agregar métodos:
  ```dart
  String? get savedToken => _prefs.getString(_kToken);
  Future<void> saveToken(String token) => _prefs.setString(_kToken, token);
  ```
- `clearSession()` debe remover también `_kToken`.

### `auth_service.dart`
- `login()`:
  - Recibir el `token` de la respuesta y llamar `_storage.saveToken(token)`.
  - Llamar `_api.setToken(token)`.
  - Dejar de guardar el `code` por separado (el JWT basta).
- `tryRestoreSession()`:
  - Leer `_storage.savedToken`.
  - Si no hay token → retornar `false`.
  - Llamar `_api.setToken(token)`.
  - Llamar `GET /auth/me` (sin query params, usa el Bearer token).
  - Construir `UserModel` desde la respuesta.
  - Si falla → llamar `_storage.clearSession()` y `_api.setToken(null)`.
- `logout()`:
  - Intentar `POST /auth/logout` (try-catch, best-effort).
  - Llamar `_storage.clearSession()`.
  - Llamar `_api.setToken(null)`.
  - Setear `_currentUser.value = null`.

### `user_model.dart`
- `UserModel.fromJson`:
  - Mapear `fullName` a `firstName` (todo excepto última palabra) y `lastName` (última palabra).
  - Mapear `institutionalEmail` a `email`.
  - Mapear `role` de inglés a español.
  - Eliminar dependencia de campos legacy del backend (`especialidades`, `courseProgress`, `career_id` numérico, etc.).
- Agregar helper `_roleToSpanish(String role)`:
  - `"student"` → `"estudiante"`
  - `"delegate"` → `"delegado"`
  - `"subdelegate"` → `"subdelegado"`
  - default → `"estudiante"`
- El `careerId`, `especialidadPrincipal`, `especialidadesInteres`, `setupComplete` se cargan desde `StorageService` después de construir el modelo base.

### `login_controller.dart`
- Sin cambios. Ya usa `AuthService.to.login()` y navega según `user.setupComplete`.

### `login_page.dart`
- Sin cambios visuales. La UI ya es correcta.

## Test Links

- Login con credenciales válidas navega a `/home` o `/setup-carrera según setupComplete`
  `[@test] ../../../test/auth/login_success_test.dart`
- Login con credenciales inválidas muestra "Código o contraseña incorrectos."
  `[@test] ../../../test/auth/login_invalid_credentials_test.dart`
- Login con campos vacíos muestra validación local sin llamar API
  `[@test] ../../../test/auth/login_empty_fields_test.dart`
- Sesión guardada se restaura al iniciar la app
  `[@test] ../../../test/auth/session_restore_test.dart`
- Sesión expirada redirige a login sin crash
  `[@test] ../../../test/auth/session_expired_test.dart`
- Logout limpia token y redirige a login
  `[@test] ../../../test/auth/logout_test.dart`
- ApiClient inyecta Bearer token en requests autenticados
  `[@test] ../../../test/services/api_client_auth_test.dart`
