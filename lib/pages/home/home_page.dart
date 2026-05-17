// lib/pages/home/home_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ulima_plus/components/footer/app_footer.dart';
import 'package:ulima_plus/components/header/app_header.dart';
import 'package:ulima_plus/pages/calculadora/calculadora_page.dart';
import 'package:ulima_plus/pages/horario_prueba/horario_prueba.dart';

import 'home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController control = Get.put(HomeController());

  int _currentIndex = 0;

  //aqui iran las paginas
  final List<Widget> _pages = [
    Center(child: Text('Malla Curricular')),
    Center(child: CalculadoraPage()),
    Center(child: HorarioPage()),
    Center(child: Text('Perfil')),
  ];

  Widget _buildBody() {
    return _pages[_currentIndex];
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    //HEADER
    return Scaffold(
      backgroundColor: colors.surface,
      body: Column(
        children: [
          const AppHeader(),

          SizedBox(height: 0.5),
          
          Divider(
            color: colors.primaryContainer,
            thickness: 2.0,
          ),

          //CUERPO
          Expanded(child: _buildBody()),
          
        ],
      ),
      //FOOTER
      bottomNavigationBar: AppFooter(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
