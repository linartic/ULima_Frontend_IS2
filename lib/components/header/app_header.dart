import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {


  final VoidCallback? onBack;

  final VoidCallback? onMail;

  const AppHeader({
    super.key,
    
    this.onBack,
    this.onMail,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      
      color: colors.surface, // Naranja Ulima

      padding: const EdgeInsets.only(
        top: 50,
        left: 20,
        right: 20,
        bottom: 15, 
      ),

      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                'ULIMA++',
                style: TextStyle(
                  color: colors.onPrimary,   // Blanco para texto sobre naranja
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // NOTIFICACIONES
              Stack(
                children: [
                  Icon(
                    Icons.notifications_none,
                    color: colors.onPrimary,   // Blanco para texto sobre naranja
                    size: 30,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}