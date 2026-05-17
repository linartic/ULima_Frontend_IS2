// lib/components/app_header.dart

import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget
    implements PreferredSizeWidget {

  final VoidCallback? onNotifications;

  const AppHeader({
    super.key,
    this.onNotifications,
  });

  @override
  Size get preferredSize => const Size.fromHeight(40);

  @override
  Widget build(BuildContext context) {
    ColorScheme colors = Theme.of(context).colorScheme;

    double screenWidth = MediaQuery.of(context).size.width;

    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: colors.primary,

      title: Text(
        'ULIMA++',
        style: TextStyle(
          color: colors.onPrimary,
          fontSize: screenWidth * 0.055,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
        ),
      ),

      actions: [
        Padding(
          padding: EdgeInsets.only(
            right: screenWidth * 0.05,
          ),

          child: InkWell(
            onTap: onNotifications,

            child: Stack(
              children: [
                Icon(
                  Icons.notifications_none,
                  color: colors.onPrimary,
                  size: screenWidth * 0.075,
                ),

                Positioned(
                  right: 0,
                  top: 0,

                  child: Container(
                    width: screenWidth * 0.022,
                    height: screenWidth * 0.022,

                    decoration: BoxDecoration(
                      color: colors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}