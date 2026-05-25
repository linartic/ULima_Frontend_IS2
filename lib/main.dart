// TERMINAL - flutter pub get

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '/configs/themes.dart';
import '/services/auth_service.dart';
import '/services/courses_service.dart';
import 'services/evaluations_service.dart';
import '/services/malla_service.dart';
import '/services/storage_service.dart';
import 'pages/home/home_page.dart';
import 'pages/login/login_page.dart';
import 'pages/setup_carrera/setup_carrera_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LucideIcons.info.codePoint;

  // Servicios globales permanentes.
  await Get.putAsync<StorageService>(
    () => StorageService().init(),
    permanent: true,
  );
  Get.put<AuthService>(AuthService(), permanent: true);
  Get.put<MallaService>(MallaService(), permanent: true);

  await Future.wait([
    EvaluationSyllabusService().loadEvaluationData(),
    CoursesService().loadCoursesData(),
    MallaService.to.load(),
  ]);

  // Intentar restaurar sesión guardada.
  final restored = await AuthService.to.tryRestoreSession();
  String initialRoute;
  if (restored) {
    final user = AuthService.to.currentUser!;
    initialRoute = user.setupComplete ? '/home' : '/setup-carrera';
  } else {
    initialRoute = '/login';
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialRoute});
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    final materialTheme = MaterialTheme(Theme.of(context).textTheme);
    return GetMaterialApp(
      title: 'ULIMA++',
      theme: materialTheme.light(),
      darkTheme: materialTheme.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      getPages: [
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/setup-carrera', page: () => const SetupCarreraPage()),
        GetPage(name: '/home', page: () => const HomePage()),
      ],
    );
  }
}
