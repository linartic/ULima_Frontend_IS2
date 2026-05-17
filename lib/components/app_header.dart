// lib/components/app_header.dart

import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {

  final String tituloCurso;

  final VoidCallback? onBack;

  final VoidCallback? onMail;

  const AppHeader({
    super.key,
    required this.tituloCurso,
    this.onBack,
    this.onMail,
  });

  @override
  Widget build(BuildContext context) {

    ColorScheme colors =
        Theme.of(context).colorScheme;

    return Container(

      color: colors.primary,

      padding: const EdgeInsets.only(
        top: 50,
        left: 20,
        right: 20,
        bottom: 10,
      ),

      child: Column(
        children: [

          // NOMBRE / ICONO??
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [

              Text(
                'ULIMA++',

                style: TextStyle(
                  color: colors.onPrimary,
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

                    color: colors.onPrimary,

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