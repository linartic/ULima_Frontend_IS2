// lib/pages/setup_carrera/setup_carrera_page.dart
// CU3 + CU4 – configuración inicial tras el primer login.
// Recrea `docs/images/UI/ConfiguracionCarrera.png`.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../configs/themes.dart';
import '../../services/auth_service.dart';
import 'setup_carrera_controller.dart';

class SetupCarreraPage extends StatelessWidget {
  const SetupCarreraPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SetupCarreraController());
    final user = AuthService.to.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      body: SafeArea(
        child: Column(
          children: [
            _SetupHeader(name: user?.firstName ?? 'Alumno'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _SectionLabel(
                      icon: LucideIcons.graduationCap,
                      title: 'Carrera',
                      subtitle:
                          'Tu carrera se asigna automáticamente según tu cuenta ULima.',
                    ),
                    const SizedBox(height: 14),
                    _LockedCarreraCard(controller: controller),
                    const SizedBox(height: 28),
                    const _SectionLabel(
                      icon: LucideIcons.bookmark,
                      title: 'Especialización',
                      subtitle:
                          'Opcional. Selecciona la mención que quieres seguir.',
                    ),
                    const SizedBox(height: 14),
                    _EspecialidadesList(controller: controller),
                    const SizedBox(height: 20),
                    _ErrorBanner(controller: controller),
                  ],
                ),
              ),
            ),
            _FinishButton(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _SetupHeader extends StatelessWidget {
  const _SetupHeader({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      decoration: const BoxDecoration(
        color: MaterialTheme.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.sparkles, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text(
                'Hola, $name',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Antes de empezar, cuéntanos qué estás estudiando.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE8DC),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: MaterialTheme.primaryDark, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF6B6B6B),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LockedCarreraCard extends StatelessWidget {
  const _LockedCarreraCard({required this.controller});
  final SetupCarreraController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE8DC),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Icon(
                LucideIcons.graduationCap,
                color: MaterialTheme.primaryDark,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Carrera asignada',
                    style: TextStyle(
                      color: Color(0xFF777777),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    controller.selectedCarreraName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline, size: 14, color: Color(0xFF777777)),
                  SizedBox(width: 4),
                  Text(
                    'Fija',
                    style: TextStyle(
                      color: Color(0xFF777777),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EspecialidadesList extends StatelessWidget {
  const _EspecialidadesList({required this.controller});
  final SetupCarreraController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: controller.especialidadesDisponibles.map((esp) {
          final espId = esp['id'] as int;
          final espName = esp['name'] as String;
          final espDesc = esp['description'] as String? ?? '';
          final selected = controller.selectedEspecialidades.contains(espId);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => controller.toggleEspecialidad(espId),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFFFF1EA) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? MaterialTheme.primaryColor
                        : const Color(0xFFE5E5E5),
                    width: selected ? 1.6 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: selected
                            ? MaterialTheme.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: selected
                              ? MaterialTheme.primaryColor
                              : const Color(0xFFCCCCCC),
                          width: 1.6,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: selected
                          ? const Icon(
                              LucideIcons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            espName,
                            style: TextStyle(
                              color: selected
                                  ? MaterialTheme.primaryDark
                                  : const Color(0xFF1A1A1A),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (espDesc.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              espDesc,
                              style: TextStyle(
                                color: selected
                                    ? MaterialTheme.primaryDark.withValues(
                                        alpha: 0.8,
                                      )
                                    : const Color(0xFF666666),
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.controller});
  final SetupCarreraController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final msg = controller.errorMessage.value;
      if (msg == null) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1EC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFFCFBF)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline,
              size: 16,
              color: MaterialTheme.primaryDark,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  color: MaterialTheme.primaryDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _FinishButton extends StatelessWidget {
  const _FinishButton({required this.controller});
  final SetupCarreraController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Obx(
          () => SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: controller.saving.value ? null : controller.finish,
              icon: controller.saving.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.2,
                      ),
                    )
                  : const Icon(LucideIcons.arrowRight, size: 20),
              label: const Text(
                'Finalizar configuración',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: MaterialTheme.primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: MaterialTheme.primaryColor.withValues(
                  alpha: 0.6,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
