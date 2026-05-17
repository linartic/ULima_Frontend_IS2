// TERMINAL - flutter pub get

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ulima_plus/pages/home/home_page.dart';
import '/configs/themes.dart';
import '/services/evaluation_syllabus_service.dart';
import '/services/courses_service.dart';

void main() async {
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
    return GetMaterialApp(
      title: 'ULIMA++',
      theme: materialTheme.light(),
      darkTheme: materialTheme.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',

      routes: {

        '/home': (context) => HomePage(),
      },

      home: HomePage(),
      
    );
  }
}