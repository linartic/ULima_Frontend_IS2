// lib/pages/home/home_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ulima_plus/components/footer/app_footer.dart';
import 'package:ulima_plus/components/header/app_header.dart';
import 'package:ulima_plus/pages/descripCursos/descrip_cursos.dart';

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
    Center(child: Text('Simulador de Notas')),
    //DESCRIPCION DE CURSOS PARA PRUEBA - AL FINAL AQUI IRIA EL HORARIO
    Center(child: DescripCursos()),
    Center(child: Text('Perfil')),
  ];

  Widget _buildBody() {
    return _pages[_currentIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppHeader(),

      body: _buildBody(),

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