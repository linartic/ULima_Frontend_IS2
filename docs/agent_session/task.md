# Implementación de Google SSO (Login Institucional)

## Backend (`ULima_Backend_IS2`)
- `[x]` Modificar base de datos
  - `[x]` Mantener `password_hash` y añadir columna opcional `google_id`.
- `[x]` Instalar dependencia `google-auth-library`.
- `[x]` Actualizar `auth.routes.ts` (añadir `/google` sin borrar `/login`).
- `[x]` Actualizar `auth.controller.ts` para soportar ambos flujos.
- `[x]` Actualizar `auth.service.ts` para verificar token con Google coexistiendo con bcrypt.

## Frontend (`ULima_Frontend_IS2`)
- `[x]` Instalar dependencia `google_sign_in` en `pubspec.yaml`.
- `[x]` Actualizar `auth_service.dart` para manejar el flujo de Google.
- `[x]` Actualizar `login_page.dart` y su controlador:
  - `[x]` Reemplazar/Añadir botón de Google.
  - `[x]` Ocultar campos de texto (o añadir divisor para flujo híbrido).
- `[ ]` Configurar `android/app/build.gradle` e `ios/Runner/Info.plist` (añadir Client IDs con placeholders).

## Verificación y Documentación
- `[ ]` Verificar cambios visuales en frontend (si aplica/compila).
- `[ ]` Crear `walkthrough.md` resumiendo los cambios implementados.
