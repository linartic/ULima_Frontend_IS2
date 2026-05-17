// main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/calculadora/calculadora_page.dart';
import '/configs/themes.dart';
import '/services/evaluation_syllabus_service.dart';
import '/services/courses_service.dart';

void main() async {
  // Inicializar servicios antes de ejecutar la app
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    EvaluationSyllabusService().loadEvaluationData(),
    CoursesService().loadCoursesData(),
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final materialTheme = MaterialTheme(Theme.of(context).textTheme);
    // IMPORTANTE: Usa GetMaterialApp y QUITA cualquier 'const' de aquí
    return GetMaterialApp(
      title: 'ULIMA++',
      theme: materialTheme.light(),
      darkTheme: materialTheme.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: CalculadoraPage(),
      
    );
  }
}
