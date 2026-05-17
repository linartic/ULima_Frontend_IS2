// TERMINAL - flutter pub get

import 'package:flutter/material.dart';
import 'package:ulima_plus/pages/home/home_page.dart';

import 'configs/theme.dart';

import 'pages/anuncios/anuncios_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    final TextTheme baseTextTheme =
        Typography.material2021().englishLike;

    final MaterialTheme materialTheme =
        MaterialTheme(baseTextTheme);

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: 'ULIMA++',

      theme: materialTheme.light(),

      darkTheme: materialTheme.dark(),

      themeMode: ThemeMode.system,

      initialRoute: '/home',

      routes: {

        '/home': (context) => HomePage(),
      },

      home: HomePage(),
    );
  }
}