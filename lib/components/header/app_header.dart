// lib/components/app_header.dart

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
    // Ya no dependemos del colorScheme por defecto para el fondo
    return Container(
      // 1. CAMBIA EL COLOR A NARANJA (o Colors.white si lo quieres blanco)
      color: colors.surface, // Naranja Ulima

      padding: const EdgeInsets.only(
        top: 50,
        left: 20,
        right: 20,
        bottom: 15, // Aumenté un poco para que respire mejor
      ),

      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                'ULIMA++',
                style: TextStyle(
                  // 2. TEXTO EN BLANCO PARA QUE RESALTE SOBRE EL NARANJA
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
                    // 3. ICONO EN BLANCO
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