# Guía de Mantenimiento - Registro de Notas

## 📝 Cómo Agregar Nuevos Cursos

Para agregar un nuevo curso con sus evaluaciones al sistema:

### 1. Editar el archivo JSON

Abra `assets/data/evaluation_syllabus.json` y agregue un nuevo objeto en el array `"cursos"`:

```json
{
  "cursoId": "650033",
  "cursoNombre": "ALGORITMOS Y ESTRUCTURAS DE DATOS",
  "evaluaciones": [
    {
      "id": "eval_020",
      "nombre": "Práctica Calificada 1",
      "sigla": "PC1",
      "peso": 20.0,
      "tipo": "practica"
    },
    {
      "id": "eval_021",
      "nombre": "Examen Parcial",
      "sigla": "EP",
      "peso": 35.0,
      "tipo": "examen"
    },
    {
      "id": "eval_022",
      "nombre": "Examen Final",
      "sigla": "EF",
      "peso": 45.0,
      "tipo": "examen"
    }
  ]
}
```

### 2. Asegurar Consistencia

- ✅ El `cursoId` debe coincidir con el ID en `curso_model.dart`
- ✅ Los `peso` deben sumar 100%
- ✅ Cada evaluación necesita un `id` único
- ✅ Los `tipo` deben ser: practica, examen, trabajo, participacion, o quiz

### 3. Actualizar curso_model.dart

Si es un curso nuevo, agregarlo a `cursosActivos`:

```dart
{
  'id': '650033',
  'nombre': 'ALGORITMOS Y ESTRUCTURAS DE DATOS',
  'ciclo': '2026-0',
  'notas': [], // Vacío inicialmente
},
```

## 🎨 Tipos de Evaluación

Cada tipo tiene un icono y color automático:

| Tipo | Icono | Color |
|------|-------|-------|
| `practica` | 📋 Assignment | Azul |
| `examen` | 🎓 School | Rojo |
| `trabajo` | 💼 Work | Verde |
| `participacion` | 👥 People | Púrpura |
| `quiz` | ❓ Quiz | Naranja |

## ⚙️ Variables de Configuración

### En `evaluation_syllabus_service.dart`

Ruta del JSON:
```dart
final jsonString = await rootBundle.loadString(
  'assets/data/evaluation_syllabus.json',  // Cambiar aquí si es necesario
);
```

### En `add_nota_with_syllabus_modal.dart`

Rango válido de notas:
```dart
if (nota < 0 || nota > 20) {  // Cambiar 20 si es otro rango
  setState(() => _valorError = 'La nota debe estar entre 0 y 20');
}
```

## 🧪 Pruebas

Para verificar que todo funciona:

1. Agregue un nuevo curso en el JSON
2. Ejecute `flutter pub get` (si cambió pubspec.yaml)
3. Ejecute `flutter run`
4. Debería ver el nuevo curso en la lista
5. Intente registrar una nota desde el nuevo curso

## 🐛 Troubleshooting

### Error: "No hay evaluaciones disponibles"

- Verifique que el `cursoId` en el JSON coincida exactamente con el ID del curso
- Asegúrese de que el archivo JSON es válido (use un validador JSON online)
- Revise la consola para mensajes de error

### Las evaluaciones no aparecen

- Confirme que el archivo está en `assets/data/`
- Verifique que `pubspec.yaml` incluye la ruta: `assets/data/evaluation_syllabus.json`
- Ejecute `flutter clean && flutter pub get && flutter run`

### Pesos no suman 100%

- Calcule la suma total de pesos en cada curso
- Debe ser exactamente 100% para que el sistema funcione correctamente

## 📦 Exportar/Importar Datos

### Generar JSON desde Backend

```dart
// Ejemplo para convertir datos de API a nuestro formato
final apiData = [
  {
    'id': '650006',
    'name': 'CÁLCULO III',
    'components': [
      {'code': 'PC1', 'name': 'Práctica 1', 'weight': 15}
    ]
  }
];

// Mapear a nuestro formato:
final formattedData = apiData.map((course) => {
  'cursoId': course['id'],
  'cursoNombre': course['name'],
  'evaluaciones': course['components'].map((c) => {
    'id': 'eval_${c['code']}',
    'nombre': c['name'],
    'sigla': c['code'],
    'peso': c['weight'].toDouble(),
    'tipo': determinarTipo(c['code']),
  }).toList()
}).toList();
```

## 📞 Soporte

Para cambios más complejos:
- Revisar documentación en `REGISTRO_NOTAS_DOCUMENTATION.md`
- Contactar al equipo de desarrollo
- Consultar código fuente en los servicios
