# Implementación de SSO Híbrido (Google + Código/Contraseña)

Este plan detalla los pasos necesarios para agregar el flujo de **Single Sign-On (SSO) con Google** (@aloe.ulima.edu.pe) a la aplicación, **manteniendo** al mismo tiempo el inicio de sesión tradicional por código y contraseña como método opcional o de respaldo, tal como fue solicitado en la validación del diseño.

## Open Questions

> [!TIP]
> 1. **Auto-registro (Provisioning):** Actualmente, la regla `BR-AUTH-07` de tus specs del backend dice: *"No existe endpoint de registro. Todos los usuarios están precargados en app_user"*. 
> Si un alumno nuevo inicia sesión con su Google `@aloe.ulima.edu.pe`, ¿el sistema debe registrarlo automáticamente en la base de datos copiando su nombre de Google, o debe rechazarlo con un error diciendo "No estás en nuestra base de datos"? (Por ahora, el plan asume que mantendremos la regla de solo admitir usuarios pre-cargados).
> 2. **Credenciales de Google Cloud:** Para probar esto localmente, necesitarás crear un proyecto en Google Cloud Console, habilitar la API de autenticación y conseguir los `Client ID` para Android, iOS y Web. ¿Ya cuentas con esto o necesitaremos configurarlo juntos durante la ejecución?

---

## Proposed Changes

A continuación se detalla qué archivos y flujos de las especificaciones actuales (`auth.spec.md` del frontend y backend) deben cambiar.

### Backend (`ULima_Backend_IS2`)

El backend mantendrá sus capacidades actuales y se le agregará un nuevo endpoint para validar tokens de Google.

#### [MODIFY] `src/db/schema/schema.ts`
- Mantener la columna `password_hash` intacta.
- Añadir columna `google_id` (opcional, para futuras vinculaciones).

#### [MODIFY] `src/modules/auth/auth.routes.ts`
- Mantener la ruta `POST /auth/login`.
- Añadir la nueva ruta `POST /auth/google`.

#### [MODIFY] `src/modules/auth/auth.controller.ts` y `auth.schemas.ts`
- Añadir `loginWithGoogle` al controlador y `googleLoginSchema` para aceptar `{ idToken: string }`.

#### [MODIFY] `src/modules/auth/auth.service.ts`
- Reemplazar la lógica de `bcryptjs.compare` con la verificación del `idToken` de Google.
- **Flujo de validación modificado:**
  1. Recibir `idToken`.
  2. Usar la librería `google-auth-library` para verificar el token contra Google.
  3. Extraer el `email` del payload de Google.
  4. Validar que `email.endsWith('@aloe.ulima.edu.pe')`. Si no → `403 INVALID_DOMAIN`.
  5. Buscar el usuario en la BD por `institutionalEmail` usando `repository.findByEmail(email)`. Si no existe → `401 USER_NOT_FOUND`.
  6. Si existe, continuar el flujo existente (validar matrícula, generar token versión, firmar JWT propio, retornar).

#### [MODIFY] Paquetes (`package.json`)
- Instalar `google-auth-library` para la validación del token de Google en el servidor.

---

### Frontend (`ULima_Frontend_IS2`)

El frontend mostrará una interfaz híbrida, similar al diseño de OTI UNI, donde el usuario puede ingresar sus credenciales tradicionales o usar el botón de Google.

#### [MODIFY] `lib/pages/login/login_page.dart`
- Mantener los `TextField` de código y contraseña y el botón "Entrar".
- Añadir un divisor visual ("O inicia sesión con") debajo del formulario principal.
- Añadir el botón "Continuar con Google".

#### [MODIFY] `lib/services/auth_service.dart`
- **Flujo de Login modificado:**
  1. Llamar a `GoogleSignIn().signIn()`.
  2. Obtener la autenticación (`GoogleSignInAuthentication`) y extraer el `idToken`.
  3. Enviar un request a `ApiClient.postJson('/auth/google', { 'idToken': idToken })`.
  4. Recibir el JWT propio de nuestro backend y guardarlo en el `StorageService` (este flujo a partir de aquí se mantiene exactamente igual al BR-AUTH-F-02).
- El proceso de *restaurar sesión* (`tryRestoreSession`) y *cerrar sesión* (`logout`) se mantiene idéntico, ya que sigue usando nuestro JWT interno. Solo habría que añadir `GoogleSignIn().signOut()` al hacer logout para limpiar la sesión local de Google.

#### [MODIFY] Configuración de Plataformas (Android/iOS)
- Configurar los archivos `android/app/build.gradle` y los `Info.plist` de iOS para soportar la librería de Google Sign In.

---

## Verification Plan

### Automated Tests
1. **Backend Tests:** Crear un test unitario en el backend que simule el payload de `google-auth-library` y verifique que correos sin dominio `@aloe.ulima.edu.pe` sean rechazados correctamente.
2. **Frontend Tests:** Actualizar los tests de login en `test/auth/` para verificar que el nuevo `AuthService.loginWithGoogle()` procese correctamente el mock token y actualice el estado local.

### Manual Verification
1. Correr la app localmente y presionar "Continuar con Google".
2. Intentar loguearse con una cuenta de `@gmail.com` personal para asegurar que el sistema lo rebote.
3. Iniciar sesión con un correo institucional pre-cargado en la base de datos y comprobar que el JWT de sesión de la app se genera correctamente y navega al `/home`.
