# Informe de Diagnóstico y Viabilidad - Nuevas Funcionalidades ULIMA++

Este documento presenta un análisis detallado sobre las propuestas de mejora y nuevas funcionalidades para la aplicación. Se desglosa qué implica cada cambio a nivel técnico, sus ventajas, desventajas y riesgos asociados.

---

## 1. Funcionalidades para Profesores (Gestión de Clases, Asesorías y Anuncios)

Se propone otorgar a los profesores la capacidad de gestionar sus horarios (mover clases y asesorías) y emitir comunicados (agregar, editar, borrar anuncios).

### Requerimientos de Modificación
*   **Base de Datos:**
    *   Implementación robusta de un sistema de Control de Acceso Basado en Roles (RBAC). Distinción clara entre `Estudiante`, `Profesor` y `Administrador`.
    *   Creación o modificación de tablas para rastrear "Reprogramaciones de Clases", "Horarios de Asesorías" y "Anuncios".
*   **Backend:**
    *   Creación de nuevos endpoints (API) exclusivos para el rol de profesor.
    *   **Lógica de validación compleja:** El sistema debe evitar colisiones de horarios y aulas. Si un profesor mueve una clase, el sistema debe validar que el aula destino esté libre y que no cruce con otras clases de los alumnos inscritos.
    *   Sistema de notificaciones push o por correo para alertar a los alumnos cuando un profesor realiza un cambio.
*   **Frontend / Móvil:**
    *   Creación de un panel de administración (Dashboard) o vistas específicas para profesores.
    *   Formularios intuitivos para la gestión de horarios y editor de texto para anuncios.

### Ventajas
*   **Autonomía y Agilidad:** Los profesores no dependen de un administrador central para gestionar imprevistos.
*   **Comunicación Directa:** Mejora la inmediatez de la comunicación entre profesor y alumno, reduciendo la desinformación sobre faltas o cambios de aula.

### Desventajas y Riesgos
> [!WARNING]
> **Riesgo de Colisiones y Caos Organizativo:** Permitir mover clases libremente puede generar cruces de horarios para los alumnos o duplicidad en la reserva de aulas si no se implementa una validación estricta.
*   **Complejidad de Desarrollo:** La lógica para validar disponibilidad de aulas y cruces de horarios de *todos* los alumnos inscritos es computacionalmente costosa y compleja de programar.

---

## 2. Mejora de la Visualización de la Malla Curricular en Móviles

Debido a las limitaciones de espacio en pantallas móviles, la visualización clásica de una malla (grafo 2D ancho) no es óptima.

### Requerimientos de Modificación
*   **UI/UX (Diseño):** Rediseñar el concepto de la malla. Alternativas:
    *   **Vista de Lista por Niveles (Acordeón):** Una lista vertical donde cada ciclo es un elemento expandible.
    *   **Navegación Interactiva (Zoom & Pan):** Un lienzo interactivo donde el usuario pueda hacer "pinch-to-zoom" (pellizcar para acercar) y arrastrar, similar a Google Maps.
    *   **Grafo Dinámico Centrado en el Curso:** Al tocar un curso, se muestran dinámicamente sus prerrequisitos hacia arriba y los cursos que desbloquea hacia abajo, ocultando el resto de la malla.
*   **Frontend:**
    *   Implementación de librerías de gestos táctiles avanzadas.
    *   Optimización de renderizado para evitar que la aplicación se vuelva lenta al cargar muchos nodos simultáneamente.

### Ventajas
*   **Mejora Crítica de UX:** Reduce la frustración del usuario. Una interfaz fluida aumenta el tiempo de retención y la percepción de calidad ("Premium") de la app.
*   **Accesibilidad:** Facilita la lectura de nombres de cursos y créditos sin tener que forzar la vista.

### Desventajas y Riesgos
> [!TIP]
> **Recomendación:** Evitar renderizar todos los nodos a la vez con librerías pesadas (ej. D3.js sin optimizar) en móviles, ya que drena la batería y reduce el rendimiento.
*   **Riesgo de Rendimiento:** Un mal manejo del DOM o de la vista de dibujo puede causar "lag" en dispositivos de gama baja.

---

## 3. Mejora del Sistema de Autenticación (SSO y MFA)

Actualmente la app depende de credenciales propias. Se propone modernizar esto mediante **Single Sign-On (SSO)** para inicios de sesión rápidos con APIs de terceros (Google, LinkedIn, GitHub) y usar **Discord** como factor de autenticación múltiple (MFA).

### 3.1 Inicio de Sesión Social (Google, LinkedIn, GitHub)
Es 100% posible, estándar en la industria y altamente recomendable. Todas estas plataformas usan el protocolo seguro **OAuth 2.0**.
*   **Google (Enfoque Recomendado y Validado):** Se propone establecer un **Login Obligatorio y Exclusivo** con Google, filtrando y permitiendo el acceso *estrictamente* a correos que terminen en `@aloe.ulima.edu.pe`. 
    *   *Ventaja Crítica:* Limpia la base de datos de usuarios falsos o bots. Garantiza que el 100% de la población de la app pertenece realmente a la universidad, creando un entorno seguro y confiable.
*   **LinkedIn/GitHub (Vinculación Opcional):** Una vez que el alumno inicia sesión con su correo de la universidad, puede "vincular" estas cuentas para que la app extraiga automáticamente su foto, nombre y enlaces profesionales (conectando a la perfección con la propuesta #6 de Networking).

### 3.2 MFA (Multi-Factor Authentication) con Discord
Añadir una capa extra de seguridad. Después de iniciar sesión, el usuario debe aprobar el ingreso mediante un código temporal que un bot envía a su cuenta de Discord vinculada.

### Requerimientos de Modificación (SSO y MFA)
*   **Base de Datos:** Añadir nuevos campos opcionales a la tabla `Student` para almacenar los identificadores externos (ej. `google_id`, `linkedin_id`, `discord_id`).
*   **Backend:**
    *   Implementación de flujos OAuth2.
    *   Crear endpoints de redirección (callback) para recibir el token de las APIs externas y generar el JWT propio de ULIMA++.
*   **Frontend (Flutter):**
    *   Reemplazar (o complementar) el formulario tradicional por botones de "Continuar con Google/LinkedIn".
    *   Para el MFA, añadir una pantalla para ingresar el código enviado por Discord.

### Ventajas
*   **Cero Fricción (Cero Contraseñas):** El alumno no tiene que inventar ni recordar contraseñas nuevas, mejorando drásticamente la experiencia de usuario (UX) en el login.
*   **Seguridad Delegada:** Las APIs de Google y LinkedIn manejan la seguridad pesada, disminuyendo el riesgo de bases de datos de contraseñas filtradas.

### Desventajas y Riesgos
> [!CAUTION]
> **Dependencia de Terceros y Bloqueo:** Si el servidor de LinkedIn o Google cae (raro, pero ocurre), nadie puede iniciar sesión. Además, si un alumno es bloqueado de su cuenta de Google, pierde acceso a ULIMA++. Se requiere **siempre** mantener un método de Login tradicional (correo/contraseña) como plan de respaldo de emergencia.

---

## 4. Integración de Tecnologías IoT (Enfocadas a la Vida Académica)

Para que el IoT se alinee directamente con el objetivo central de ULIMA++ (gestión académica, perfiles de estudiantes y flujos de delegados), las implementaciones deben enfocarse en el ecosistema del aula, el estudio y la relación profesor-alumno, de forma no invasiva:

### Ideas Propuestas (Alineadas al Core Académico)
1.  **Cerraduras Inteligentes para Cubículos de Estudio:** Dado que la app ya maneja módulos de horarios, podría gestionar la reserva de cubículos. Un pequeño dispositivo IoT en la puerta permitiría al estudiante abrirla usando NFC o Bluetooth desde la app de ULIMA++, pero solo durante su hora exacta de reserva.
2.  **Sensores de Disponibilidad en Laboratorios (PCs):** En lugar de cámaras invasivas, se monitorea el estado de red de las computadoras de los laboratorios. La app mostraría en la sección académica: *"Laboratorio 402: 5 PCs libres para hacer trabajos"*, ayudando directamente a la productividad del alumno.
3.  **Estado "On-Air" para Asesorías de Profesores:** Un pequeño sensor o botón físico en la puerta de la oficina de los profesores. Cuando el profesor llega y está dispuesto a recibir consultas libres (asesorías), presiona el botón. La app notifica automáticamente a sus alumnos: *"El profesor de IS2 está disponible ahora en su oficina"*. Esto potencia enormemente la funcionalidad de "Asesorías".
4.  **Pantallas E-Ink Inteligentes en Aulas:** Pequeñas pantallas de tinta electrónica en la puerta de cada aula, conectadas al backend de ULIMA++. Si un profesor o delegado reprograma una clase o cambia el aula (usando la propuesta #1), la pantalla física del aula se actualiza automáticamente para avisar a los alumnos despistados, conectando la app con el mundo real.

### Requerimientos de Modificación
*   **Hardware:** Adquisición de cerraduras electrónicas simples (Bluetooth/NFC), botones IoT para profesores y pantallas E-Ink de bajo consumo.
*   **Backend / API:**
    *   Endpoints específicos para sincronizar el estado del hardware IoT con los módulos existentes de `Schedules` y `Course detail`.
*   **Frontend (Flutter):**
    *   Integración de un botón interactivo "Abrir Cubículo" (vía NFC/BLE) y vistas en tiempo real para ver la disponibilidad de PCs y profesores.

### Ventajas
*   **Sinergia Perfecta:** Expande las funcionalidades ya existentes de ULIMA++ (horarios, asesorías, anuncios) al mundo físico, resolviendo problemas reales del día a día académico del estudiante.
*   **Cero Invasivo:** No rastrea constantemente el GPS ni el celular del alumno. El alumno es quien decide interactuar (ej. abrir una puerta) y el profesor quien decide avisar su disponibilidad.

### Desventajas y Riesgos
> [!IMPORTANT]
> **Adopción Docente:** El sistema de "Estado On-Air" requiere que los profesores adquieran el hábito de usar el botón físico al llegar a su oficina. Si no lo usan, la funcionalidad se vuelve inútil.
*   **Mantenimiento Físico:** Las cerraduras electrónicas y pantallas requieren cambio de baterías y soporte técnico físico continuo por parte de la universidad.

---

## 5. Automatización de Ingesta de Datos (ETL desde PDFs y Archivos)

La idea es eliminar el trabajo manual de cargar datos (horarios, sílabos, mallas) desde los archivos oficiales de la universidad (PDFs o Excels) directamente a la base de datos de forma automática.

### Requerimientos de Modificación
*   **Backend (Pipelines de Datos / ETL):**
    *   **Extracción (Extract):** Implementar herramientas de parseo de PDFs (ej. `pdfplumber`, `PyMuPDF`) o, si los formatos son muy complejos o visuales, usar APIs de modelos de lenguaje multimodales (Visión) para extraer datos estructurados con Inteligencia Artificial.
    *   **Transformación (Transform):** Uso de algoritmos de limpieza de texto (Regex) para identificar, limpiar y clasificar qué texto corresponde al nombre del curso, código, profesor, días, horas y aulas.
    *   **Carga (Load):** Scripts de inserción masiva (`bulk insert`) para poblar automáticamente los schemas de la base de datos.
*   **Frontend (Panel de Administrador):**
    *   Una interfaz para arrastrar y soltar (Drag & Drop) los PDFs de la universidad.
    *   **Crucial:** Una vista previa interactiva de los datos extraídos (formato tabla) *antes* de confirmarlos en la base de datos. Esto permite que el administrador edite manualmente cualquier campo que el parser haya leído mal.

### Ventajas
*   **Ahorro de Tiempo Drástico:** Reduce días de "Data Entry" agotador a un flujo de trabajo que toma unos pocos minutos.
*   **Reducción de Errores Tipográficos:** Aunque la máquina puede equivocarse, elimina el error humano por fatiga al teclear cientos de códigos de cursos.

### Desventajas y Riesgos
> [!WARNING]
> **Sensibilidad a Cambios de Formato:** Los scripts de extracción basados en coordenadas o patrones de texto son frágiles. Si el siguiente semestre la universidad añade una columna nueva al PDF o cambia el diseño, el script dejará de funcionar y requerirá mantenimiento del código.
*   **Falsos Positivos/Negativos:** Especialmente con PDFs escaneados (donde se usa OCR), la lectura puede fallar (ej. leer un '8' en lugar de una 'B').

---

## 6. Mejora del Perfil de Estudiante (Networking y Enlaces Rápidos)

Actualmente, el perfil del estudiante se centra en datos netamente académicos. Agregar una capa de "Networking Profesional" ayudaría a los alumnos a conectar. Existen dos enfoques posibles para implementarlo:

**Opción A: Acceso Rápido (Networking Pasivo)**
Consiste en añadir íconos con enlaces (LinkedIn, GitHub) en la pantalla de "Contactos de la Sección" o en el perfil de usuario.
*   **Pros:** Es un *Quick Win* (victoria rápida). Toma muy poco esfuerzo de programación (simplemente añadir campos en la BD y usar un botón con `url_launcher` en Flutter).
*   **Contras:** Es pasivo. Depende de que un alumno busque el perfil de otro en la lista de la clase de forma proactiva.

**Opción B: Compartido Rápido / Tarjeta Digital (Networking Activo)**
Consiste en generar un **Código QR personal** dentro de la app o usar **NFC** (como un "Bump" de teléfonos). Cuando dos compañeros se conocen en el campus, abren ULIMA++, uno muestra su QR y el otro lo escanea para intercambiar sus LinkedIn al instante.
*   **Pros:** Fomenta la interacción cara a cara. Tiene un factor "Wow" muy alto, es dinámico y se siente como una app extremadamente moderna (como una tarjeta de presentación digital integrada).
*   **Contras:** Requiere más esfuerzo técnico en el frontend (implementar generadores y lectores de QR en Flutter, gestionar permisos de cámara, etc.).

### Requerimientos de Modificación (Comunes a ambas opciones)
*   **Base de Datos y Backend:** Nuevos campos opcionales (`linkedin_url`, `github_url`) en el perfil del usuario y endpoints (PATCH) para actualizarlos.
*   **Frontend (Flutter):** 
    *   Formulario para que el alumno pegue las URLs de sus redes.
    *   Para la *Opción A*: Botones de hipervínculo visuales en la interfaz.
    *   Para la *Opción B*: Uso de librerías como `qr_flutter` (para generar) y `mobile_scanner` (para leer códigos QR).

### Ventajas del Networking en ULIMA++
*   **Crea Comunidad:** Conecta la vida académica de la universidad con el futuro profesional de los estudiantes, facilitando la creación de redes de contacto.

### Desventajas y Riesgos
> [!TIP]
> **Privacidad por Diseño:** Es crítico que configurar estas redes sea 100% opcional. Además, se debe incluir un ajuste de privacidad: un alumno podría querer compartir su LinkedIn *solo en persona mediante QR* (Opción B), pero mantenerlo oculto en la lista pública de contactos de la sección (Opción A).

---

### Resumen del Diagnóstico

Las propuestas son altamente valiosas y apuntan a modernizar la experiencia universitaria.
Se recomienda priorizar las tareas según un balance de **Impacto vs. Esfuerzo**:
1.  **Prioridad Alta (Gran Impacto visual, Bajo riesgo sistémico):** Rediseño de la malla curricular para móviles.
2.  **Prioridad Media (Gran utilidad, Alto riesgo lógico):** Funcionalidades para profesores (requiere diseño de base de datos y validaciones muy cuidadosas).
3.  **Prioridad Baja/Aislada (Alta seguridad, Riesgo de soporte):** MFA con Discord (Hacerlo opcional en una primera fase).
4.  **Fase "Smart Campus" (Alto Impacto, Muy alto costo/esfuerzo):** IoT. Se sugiere empezar con un "Piloto" pequeño (ej. rastreo de 1 bus o aforo de 1 sola sala) para validar la tecnología antes de un despliegue masivo.
