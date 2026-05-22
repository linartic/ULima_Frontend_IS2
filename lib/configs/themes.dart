// lib/configs/theme.dart

import 'package:flutter/material.dart';

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static const Color primaryColor = Color(0xFFFF6600);

  static const Color primaryDark = Color(0xFFD45500);

  static const Color blackColor = Color(0xFF1A1A1A);

  static const Color greyColor = Color.fromARGB(255, 32, 32, 32);

  static const Color whiteColor = Color(0xFFFFFFFF);

  //FONDO HEADER
  static Color headerColor(Brightness brightness) {
    return brightness == Brightness.light
        ? primaryColor
        : Color.fromARGB(255, 30, 30, 36);
  }

  //INFO CURSOS
  static Color bloqueCurso(Brightness brightness) {
    return brightness == Brightness.light
        ? const Color(0xFFFF7A1A)
        : primaryColor;
  }

  static Color bloqueSeccion(Brightness brightness) {
    return brightness == Brightness.light
        ? const Color(0xFFFFD8C2)
        : const Color(0xFF4A332B);
  }

  static Color bloqueAsistencia(Brightness brightness) {
    return brightness == Brightness.light
        ? const Color(0xFFFFE8DC)
        : const Color(0xFF342B2F);
  }

  static Color bloqueAsistenciaLinea(Brightness brightness) {
    return brightness == Brightness.light
        ? const Color(0xFFE3B08C)
        : const Color(0xFFFFB088);
  }

  // LIGHT SCHEME
  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,

      primary: primaryColor,

      onPrimary: whiteColor,

      primaryContainer: primaryColor,

      onPrimaryContainer: blackColor,

      secondary: primaryDark,

      onSecondary: whiteColor,

      secondaryContainer: Color(0xFFFFD1B3),

      onSecondaryContainer: blackColor,

      tertiary: Color.fromARGB(255, 58, 58, 58),

      onTertiary: whiteColor,

      tertiaryContainer: Color(0xFFEAEAEA),

      onTertiaryContainer: blackColor,

      error: Colors.red,

      onError: whiteColor,

      surface: Color.fromARGB(255, 254, 253, 252),

      onSurface: blackColor,

      outline: Color(0xFFDADADA),

      shadow: Colors.black,

      inverseSurface: blackColor,

      onInverseSurface: whiteColor,

      inversePrimary: primaryDark,
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  // DARK SCHEME
  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,

      primary: primaryColor,

      onPrimary: whiteColor,

      primaryContainer: primaryDark,

      onPrimaryContainer: Color.fromARGB(255, 42, 42, 42),

      secondary: Color(0xFFFF8C42),

      onSecondary: blackColor,

      secondaryContainer: greyColor,

      onSecondaryContainer: whiteColor,

      tertiary: Color(0xFFBDBDBD),

      onTertiary: blackColor,

      tertiaryContainer: greyColor,

      onTertiaryContainer: whiteColor,

      error: Colors.red,

      onError: whiteColor,

      surface: Color.fromARGB(255, 30, 30, 36),

      onSurface: whiteColor,

      outline: Color(0xFF444444),

      shadow: Colors.black,

      inverseSurface: whiteColor,

      onInverseSurface: blackColor,

      inversePrimary: primaryDark,
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  ThemeData theme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,

      brightness: colorScheme.brightness,

      colorScheme: colorScheme,

      scaffoldBackgroundColor: colorScheme.surface,

      canvasColor: colorScheme.surface,

      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,

          foregroundColor: colorScheme.onPrimary,

          padding: const EdgeInsets.symmetric(vertical: 16),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: colorScheme.surface,

        elevation: 2,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      textTheme: textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
    );
  }
}
