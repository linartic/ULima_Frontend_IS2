# Módulo de Registro de Notas - Documentación

## 📋 Resumen

Se ha implementado un módulo frontend completo para el registro de notas con filtrado automático de evaluaciones del sílabo. El sistema está diseñado para ser escalable y permite la fácil transición de datos locales (JSON) a una API dinámica en el futuro.

## 🏗️ Arquitectura

### Estructura de Archivos

```
lib/
├── models/
│   ├── curso_model.dart          # Modelo del curso (existente)
│   └── evaluation_model.dart     # NUEVO: Modelos de evaluaciones y sílabo
│
├── services/
│   └── evaluation_syllabus_service.dart  # NUEVO: Servicio para cargar datos
│
├── components/calculadora/
│   ├── curso_card.dart           # Tarjeta del curso (existente)
│   ├── add_nota_with_syllabus_modal.dart  # NUEVO: Modal mejorado
│   ├── syllabus_info_panel.dart  # NUEVO: Panel informativo del sílabo
│   └── syllabus_evaluation_selector.dart  # NUEVO: Selector de evaluaciones
│
├── pages/calculadora/
│   ├── calculadora_page.dart     # Página principal (actualizada)
│   └── calculadora_controller.dart   # Controlador (actualizado)
│
├── main.dart                     # Entrada (actualizado)
│
assets/data/
└── evaluation_syllabus.json      # NUEVO: Datos locales de evaluaciones
```

## 🔑 Componentes Principales

### 1. **Models** (`evaluation_model.dart`)

```dart
class EvaluationComponent {
  final String id;
  final String nombre;      // Ej: "Práctica Calificada 1"
  final String sigla;       // Ej: "PC1"
  final double peso;        // Peso en porcentaje
  final String tipo;        // Tipo: practica, examen, trabajo, etc.
}

class CourseSyllabus {
  final String cursoId;
  final String cursoNombre;
  final List<EvaluationComponent> evaluaciones;
  final double pesoTotal;   // Suma automática de pesos
}
```

### 2. **Service** (`evaluation_syllabus_service.dart`)

Servicio singleton que:
- Carga el archivo JSON al iniciar
- Proporciona acceso rápido a datos por curso ID
- Gestiona caché de datos en memoria

```dart
// Obtener evaluaciones de un curso
final evaluaciones = service.getEvaluationsByCourseId('650006');

// Obtener sílabo completo
final syllabus = service.getSyllabusByCourseId('650006');
```

### 3. **Controlador** (`calculadora_controller.dart`)

Actualizado con:
- Integración del servicio de sílabo
- Métodos para acceder a evaluaciones por índice de curso
- Métodos helper para verificar disponibilidad de datos

```dart
// Obtener sílabo del curso en el índice
final syllabus = controller.getSyllabusForCourse(index);

// Obtener evaluaciones disponibles
final evaluaciones = controller.getEvaluationsForCourse(index);

// Verificar si hay datos del sílabo
if (controller.hasSyllabusData(index)) { ... }
```

### 4. **Componentes UI**

#### `add_nota_with_syllabus_modal.dart`
Modal mejorado que:
- Muestra todas las evaluaciones disponibles del sílabo
- Auto-completa el peso desde el sílabo
- Valida la nota registrada
- Mantiene consistencia con el sílabo

#### `syllabus_info_panel.dart`
Panel informativo que:
- Muestra resumen de evaluaciones del sílabo
- Indica peso total disponible
- Agrupa por tipo de evaluación

#### `syllabus_evaluation_selector.dart`
Selector visual que:
- Lista todas las evaluaciones con iconos por tipo
- Permite seleccionar evaluación para registrar nota
- Muestra pesos e información detallada

## 📊 Datos JSON

```json
{
  "cursos": [
    {
      "cursoId": "650006",
      "cursoNombre": "CÁLCULO III",
      "evaluaciones": [
        {
          "id": "eval_001",
          "nombre": "Práctica Calificada 1",
          "sigla": "PC1",
          "peso": 15.0,
          "tipo": "practica"
        },
        ...
      ]
    }
  ]
}
```

## 🎯 Flujo de Uso

1. **Inicialización** → `main.dart` carga el servicio antes de ejecutar la app
2. **Carga de Datos** → Controlador obtiene datos del sílabo al iniciar
3. **Visualización** → Se muestra panel de sílabo para cada curso
4. **Registro** → Usuario selecciona evaluación del sílabo y registra nota
5. **Actualización** → Peso se obtiene automáticamente del sílabo

## 🔄 Transición a API

Para reemplazar el JSON local con una API:

### Paso 1: Extender el servicio

```dart
// evaluation_syllabus_service.dart

Future<void> loadEvaluationDataFromAPI(String userId) async {
  try {
    final response = await http.get(
      Uri.parse('https://api.example.com/syllabus/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    final data = jsonDecode(response.body);
    _syllabusData = (data['cursos'] as List)
        .map((c) => CourseSyllabus.fromJson(c))
        .toList();
    
    _isLoaded = true;
  } catch (e) {
    print('Error loading from API: $e');
  }
}
```

### Paso 2: Actualizar main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final service = EvaluationSyllabusService();
  // Cambiar a:
  await service.loadEvaluationDataFromAPI(userId);
  
  runApp(const MyApp());
}
```

### Paso 3: Integrar extracción de PDF

```dart
// syllabus_extraction_service.dart (nuevo)

class SyllabusExtractionService {
  Future<CourseSyllabus> extractFromPDF(File pdfFile) async {
    // Usar librería como `pdf` o `pdfx`
    // Parsear evaluaciones del documento
    return CourseSyllabus(...);
  }
}
```

## 📋 Características Implementadas

✅ Carga de datos locales desde JSON  
✅ Filtrado automático por curso  
✅ Visualización de evaluaciones del sílabo  
✅ Auto-completado de pesos  
✅ Panel informativo con resumen  
✅ Validación de notas  
✅ Soporte para múltiples cursos  
✅ Arquitectura escalable para API  

## 🚀 Próximos Pasos

1. **API Backend** → Implementar endpoint para obtener sílabus
2. **Extracción de PDF** → Agregar librería de lectura de PDF
3. **Autenticación** → Vincular a usuario específico
4. **Persistencia** → Guardar notas en base de datos
5. **Reportes** → Generar reportes de desempeño

## 🧪 Prueba Local

1. Compile y ejecute: `flutter run`
2. Navegue a la sección "Calculadora de Notas"
3. Verá el panel de sílabo para cada curso
4. Haga clic en "Registrar Nota"
5. Seleccione una evaluación del sílabo
6. Registre la nota (0-20)
7. El peso se completará automáticamente

## 📝 Notas

- Los datos están en `assets/data/evaluation_syllabus.json`
- El servicio usa patrón Singleton para eficiencia
- Los datos se cargan en memoria al iniciar
- Todo es reactivo (GetX) para UI responsive
- Compatible con modo claro/oscuro

---

**Versión**: 1.0  
**Última actualización**: 2026-05-16
