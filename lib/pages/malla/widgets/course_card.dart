// lib/pages/malla/widgets/course_card.dart
// Tarjeta individual de un curso en la malla.

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../models/malla_models.dart';
import '../malla_controller.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    required this.status,
    required this.onTap,
    required this.onLongPress,
  });

  final CourseNode course;
  final CourseStatus status;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  IconData get _statusIcon {
    switch (status) {
      case CourseStatus.approved:
        return LucideIcons.check;
      case CourseStatus.current:
        return LucideIcons.circleDot;
      case CourseStatus.unlocked:
        return LucideIcons.circle;
      case CourseStatus.locked:
        return LucideIcons.lock;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = status == CourseStatus.locked;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: MallaController.cardWidth,
          height: MallaController.cardHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: status.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: status.borderColor, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Opacity(
            opacity: isLocked ? 0.65 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      course.code,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: Icon(_statusIcon, color: Colors.white, size: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Center(
                    child: Text(
                      course.name,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      child: Text(
                        '${course.credits} CR',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (course.isElective)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        child: const Text(
                          'ELECTIVO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
