# Configuración de Google Cloud para SSO en ULIMA++

Para que el inicio de sesión con Google funcione correctamente en tu aplicación (y deje de salir el error *"No se pudo iniciar sesión con Google"*), necesitas generar **credenciales de acceso** oficiales. Esto es completamente gratuito.

Sigue esta guía paso a paso para configurar tu entorno en la consola de Google.

---

## Parte 1: Crear el Proyecto y la Pantalla de Consentimiento

> [!IMPORTANT]
> Debes usar una cuenta de Google que tenga acceso a crear proyectos en Cloud. De preferencia tu cuenta personal o institucional principal.

1. Ingresa a la [Consola de Google Cloud](https://console.cloud.google.com/).
2. Haz clic en el selector de proyectos en la esquina superior izquierda y selecciona **"Nuevo Proyecto"**.
   - **Nombre:** `ULima Plus` (o similar).
   - Haz clic en **Crear**.
3. En el menú de navegación izquierdo (las 3 rayitas), ve a **APIs y Servicios** > **Pantalla de consentimiento de OAuth**.
4. Selecciona **Externo** (a menos que tu cuenta de Google Cloud pertenezca al directorio `@aloe.ulima.edu.pe`, en cuyo caso puedes elegir *Interno*).
5. Rellena la información básica:
   - **Nombre de la aplicación:** ULima++
   - **Correo electrónico de asistencia:** Tu correo.
   - **Dominio autorizado:** (Puedes dejarlo en blanco por ahora, o poner el dominio de tu backend si lo tuvieras).
   - **Datos de contacto del desarrollador:** Tu correo.
   - Presiona **Guardar y Continuar**.
6. En la sección **Permisos (Scopes)**, asegúrate de añadir:
   - `.../auth/userinfo.email`
   - `.../auth/userinfo.profile`
   - `openid`
7. Termina el asistente de la pantalla de consentimiento. Si elegiste *Externo*, añade tu propio correo institucional a los **Usuarios de prueba** para que puedas usarlo mientras la app esté en modo desarrollo.

---

## Parte 2: Crear las Credenciales (Client IDs)

Necesitas generar un "Client ID" para cada plataforma en la que correrá tu app.

1. Ve a **APIs y Servicios** > **Credenciales**.
2. Haz clic en **+ CREAR CREDENCIALES** > **ID de cliente de OAuth**.

### A. Para Flutter Web (Lo que estamos probando ahora)
- **Tipo de aplicación:** Aplicación web
- **Nombre:** `Web Client ULima++`
- **Orígenes de JavaScript autorizados:** 
  - `http://localhost`
  - `http://localhost:55930` (Añade el puerto en el que suele correr Flutter web en tus pruebas. Si el puerto cambia mucho, añade varios o simplemente usa `http://localhost`).
- **URI de redireccionamiento autorizados:** Déjalo en blanco.
- Haz clic en **Crear**. 
- **Copia el ID de cliente generado** (termina en `.apps.googleusercontent.com`).

### B. Para Android (Opcional por ahora, hazlo cuando compiles el APK)
- Repite el paso 2, pero elige **Aplicación para Android**.
- Te pedirá el **Nombre del paquete** (ej. `com.example.ulima_plus`). Lo encuentras en tu `android/app/build.gradle`.
- Te pedirá la **huella digital SHA-1**. Esta se obtiene corriendo el comando `./gradlew signingReport` en la carpeta `android` de tu proyecto Flutter.

---

## Parte 3: Inyectar el Client ID en el Código

### 1. En el Frontend (Flutter)

Abre el archivo `lib/services/auth_service.dart` y busca el método `loginWithGoogle`. Necesitas pasarle explícitamente el `clientId` web que copiaste en el Paso 2A:

```dart
// lib/services/auth_service.dart (Línea ~102)

final GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: ['email'],
  // Pega aquí tu Client ID Web
  clientId: 'TU_CLIENT_ID_WEB.apps.googleusercontent.com', 
);
```

> [!TIP]
> En Flutter Web, al definir el `clientId` directamente en la instancia de `GoogleSignIn()`, ya no es estrictamente necesario tocar el archivo `web/index.html`. 

### 2. En el Backend (Opcional pero Recomendado para Seguridad)

Para evitar que alguien falsifique un token, el backend debería verificar que el token de Google fue generado específicamente para **tu Client ID**.

Abre `ULima_Backend_IS2/src/modules/auth/auth.service.ts`:

```typescript
// src/modules/auth/auth.service.ts (Línea ~60)

const ticket = await googleClient.verifyIdToken({
  idToken: input.idToken,
  audience: "TU_CLIENT_ID_WEB.apps.googleusercontent.com", // <-- Añade esto
});
```
*Nota: Si vas a tener clientes de iOS y Android en el futuro, `audience` puede ser un arreglo de strings `["ID_WEB", "ID_ANDROID", "ID_IOS"]`.*

---

## Resumen

Una vez que completes estos pasos y guardes los archivos, al presionar el botón "Continuar con Google" en tu app local, se abrirá correctamente la ventana de autorización y la app fluirá directamente hacia tu Home.
