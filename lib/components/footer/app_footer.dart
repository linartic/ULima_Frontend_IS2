// lib/components/app_footer.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';


class AppFooter extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const AppFooter({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colors = Theme.of(context).colorScheme;

    return BottomNavigationBar(
      currentIndex: currentIndex,

      onTap: (index) {
        if (onTap != null) {
          onTap!(index);
        }
      },

      selectedItemColor: colors.primary,
      unselectedItemColor: Colors.grey,

      type: BottomNavigationBarType.fixed,

      items: const [
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.network),
          label: 'Malla',
        ),

        BottomNavigationBarItem(
          icon: Icon(LucideIcons.calculator),
          label: 'Notas',
        ),

        BottomNavigationBarItem(
          icon: Icon(LucideIcons.calendar),

          label: 'Horario',
        ),

        /*
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.shield),
          label: 'Delegado',
        ),
        */

        BottomNavigationBarItem(
          icon: Icon(LucideIcons.user),
          label: 'Perfil',
        ),
      ],
    );
  }
}
