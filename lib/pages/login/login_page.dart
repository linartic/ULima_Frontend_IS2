// lib/pages/login/login_page.dart
// CU1 – Inicio de sesión.
// Recrea fielmente el mockup de Figma:
//   - Fondo naranja institucional en light mode.
//   - Card centrada con esquinas redondeadas y sombra suave.
//   - Logo SVG de la Universidad de Lima.
//   - Inputs minimalistas con sólo línea inferior (sin íconos, sin caja).
//   - Botón "Entrar" naranja con esquinas redondeadas.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../configs/themes.dart';
import 'login_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    final palette = _LoginPalette.from(context);

    return Scaffold(
      backgroundColor: palette.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: _LoginCard(controller: controller, palette: palette),
          ),
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({required this.controller, required this.palette});
  final LoginController controller;
  final _LoginPalette palette;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: palette.cardBorder),
          boxShadow: [
            BoxShadow(
              color: palette.cardShadow,
              blurRadius: 32,
              offset: Offset(0, 18),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 40, 32, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: SvgPicture.asset(
                  'assets/images/Universidad_de_Lima_logo.svg',
                  width: 150,
                  colorMapper: palette.logoColorMapper,
                  semanticsLabel: 'Universidad de Lima',
                ),
              ),
              const SizedBox(height: 32),
              _UnderlineField(
                controller: controller.codeController,
                palette: palette,
                hint: 'Código',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
              ),
              const SizedBox(height: 18),
              _UnderlineField(
                controller: controller.passwordController,
                palette: palette,
                hint: 'Contraseña',
                obscureText: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) => controller.submit(),
              ),
              _ErrorMessage(controller: controller, palette: palette),
              const SizedBox(height: 28),
              _EntrarButton(controller: controller, palette: palette),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnderlineField extends StatelessWidget {
  const _UnderlineField({
    required this.controller,
    required this.palette,
    required this.hint,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final _LoginPalette palette;
  final String hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onSubmitted: onSubmitted,
      cursorColor: palette.cursor,
      style: TextStyle(
        color: palette.fieldText,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: palette.fieldHint,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        isDense: true,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: palette.fieldLine),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: palette.fieldLine),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: palette.focusedFieldLine, width: 1.5),
        ),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.controller, required this.palette});
  final LoginController controller;
  final _LoginPalette palette;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final msg = controller.errorMessage.value;
      if (msg == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(
          msg,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: palette.error,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    });
  }
}

class _EntrarButton extends StatelessWidget {
  const _EntrarButton({required this.controller, required this.palette});
  final LoginController controller;
  final _LoginPalette palette;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: controller.submitting.value ? null : controller.submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: palette.buttonBackground,
            foregroundColor: palette.buttonForeground,
            disabledBackgroundColor: palette.disabledButtonBackground,
            disabledForegroundColor: palette.disabledButtonForeground,
            elevation: 0,
            padding: EdgeInsets.zero,
            side: palette.buttonSide,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: controller.submitting.value
              ? SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: palette.buttonForeground,
                    strokeWidth: 2.2,
                  ),
                )
              : Text(
                  'Entrar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}

class _LoginPalette {
  const _LoginPalette({
    required this.background,
    required this.card,
    required this.cardBorder,
    required this.cardShadow,
    required this.fieldText,
    required this.fieldHint,
    required this.fieldLine,
    required this.focusedFieldLine,
    required this.cursor,
    required this.error,
    required this.buttonBackground,
    required this.buttonForeground,
    required this.disabledButtonBackground,
    required this.disabledButtonForeground,
    required this.buttonSide,
    this.logoColorMapper,
  });

  factory _LoginPalette.from(BuildContext context) {
    final isDark = Theme.brightnessOf(context) == Brightness.dark;

    if (isDark) {
      return const _LoginPalette(
        background: Color(0xFF262626),
        card: Color(0xFF050505),
        cardBorder: Color(0xFF262626),
        cardShadow: Color(0x99000000),
        fieldText: Color(0xFFF4F4F4),
        fieldHint: Color(0xFFEDEDED),
        fieldLine: Color(0xFFE7E7E7),
        focusedFieldLine: Color(0xFFFA7525),
        cursor: Color(0xFFFA7525),
        error: Color(0xFFFA7525),
        buttonBackground: Color(0x00000000),
        buttonForeground: Color(0xFFF4F4F4),
        disabledButtonBackground: Color(0x00000000),
        disabledButtonForeground: Color(0xFF8F8F8F),
        buttonSide: BorderSide(color: Color(0xFFE7E7E7), width: 1.5),
        logoColorMapper: _LogoTextColorMapper(Color(0xFFF4F4F4)),
      );
    }

    return const _LoginPalette(
      background: MaterialTheme.primaryColor,
      card: Colors.white,
      cardBorder: Colors.transparent,
      cardShadow: Color(0x33000000),
      fieldText: Color(0xFF1A1A1A),
      fieldHint: Color(0xFF9B9B9B),
      fieldLine: Color(0xFFCFCFCF),
      focusedFieldLine: MaterialTheme.primaryColor,
      cursor: MaterialTheme.primaryColor,
      error: MaterialTheme.primaryDark,
      buttonBackground: MaterialTheme.primaryColor,
      buttonForeground: Colors.white,
      disabledButtonBackground: Color(0x99FF6600),
      disabledButtonForeground: Colors.white,
      buttonSide: BorderSide.none,
    );
  }

  final Color background;
  final Color card;
  final Color cardBorder;
  final Color cardShadow;
  final Color fieldText;
  final Color fieldHint;
  final Color fieldLine;
  final Color focusedFieldLine;
  final Color cursor;
  final Color error;
  final Color buttonBackground;
  final Color buttonForeground;
  final Color disabledButtonBackground;
  final Color disabledButtonForeground;
  final BorderSide buttonSide;
  final ColorMapper? logoColorMapper;
}

class _LogoTextColorMapper extends ColorMapper {
  const _LogoTextColorMapper(this.textColor);

  final Color textColor;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (color == Colors.black || color == const Color(0xFF000000)) {
      return textColor;
    }

    return color;
  }

  @override
  bool operator ==(Object other) {
    return other is _LogoTextColorMapper && other.textColor == textColor;
  }

  @override
  int get hashCode => textColor.hashCode;
}
