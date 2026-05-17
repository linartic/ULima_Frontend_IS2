import 'package:flutter/material.dart';
import 'package:ulima_plus/configs/themes.dart';
class AppHeader extends StatelessWidget {


  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: MaterialTheme.headerColor(Theme.brightnessOf(context)),
        border: Border(
          bottom: BorderSide(
            color: colors.primaryContainer,
            width: 2.0,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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