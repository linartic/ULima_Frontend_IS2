// lib/components/app_footer.dart
// FOOTER PRUEBA - SI LES SALE MEJOR XFA CAMABIARLO

import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  final int currentIndex;

  final Function(int)? onTap;

  const AppFooter({super.key, required this.currentIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,

      onTap: onTap,

      selectedItemColor: const Color(0xFFE65100), // El naranja que estás usando
      unselectedItemColor: Colors.grey,

      type: BottomNavigationBarType.fixed,

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.account_tree_outlined),
          label: 'MALLA',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.calculate_outlined),
          label: 'NOTAS',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          label: 'HORARIO',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'PERFIL',
        ),
      ],
    );
  }
}
