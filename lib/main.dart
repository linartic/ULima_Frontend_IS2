// TERMINAL - flutter pub get

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/configs/themes.dart';
import '/services/auth_service.dart';
import '/services/courses_service.dart';
import 'services/evaluations_service.dart';
import '/services/malla_service.dart';
import 'pages/home/home_page.dart';
import 'pages/login/login_page.dart';
import 'pages/setup_carrera/setup_carrera_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Servicios globales permanentes para todo el ciclo de vida de la app.
  Get.put<AuthService>(AuthService(), permanent: true);
  Get.put<MallaService>(MallaService(), permanent: true);
  await Future.wait([
    EvaluationSyllabusService().loadEvaluationData(),
    CoursesService().loadCoursesData(),
    MallaService.to.load(),
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final materialTheme = MaterialTheme(Theme.of(context).textTheme);
    return GetMaterialApp(
      title: 'ULIMA++',
      theme: materialTheme.light(),
      darkTheme: materialTheme.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/setup-carrera', page: () => const SetupCarreraPage()),
        GetPage(name: '/home', page: () => const HomePage()),
      ],
    );
  }
}
