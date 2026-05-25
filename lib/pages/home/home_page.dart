// lib/pages/home/home_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ulima_plus/components/footer/app_footer.dart';
import 'package:ulima_plus/components/header/app_header.dart';
import 'package:ulima_plus/pages/calculadora/calculadora_page.dart';
import 'package:ulima_plus/pages/horario/horario.dart';
import 'package:ulima_plus/pages/malla/malla_page.dart';
import 'package:ulima_plus/services/auth_service.dart';
import '../perfil/perfil.dart';

import 'home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController control = Get.put(HomeController());
  final user = AuthService.to.currentUser;

  int _currentIndex = 0;

  //aqui iran las paginas
  late final List<Widget> _pages = [
    const MallaPage(),
    const CalculadoraPage(),
    const HorarioPage(),

    // MODULO EXTRA A LOS ALUMNOS CON ROL 'Delegado'
    if (user?.isDelegate ?? false) const Center(child: Text('Delegado')),

    const ProfilePage(),
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
