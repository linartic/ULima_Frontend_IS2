// lib/pages/malla/widgets/course_card.dart
// Tarjeta individual de un curso en la malla.
// Los electivos se diferencian de los obligatorios por un borde discontinuo.

import 'package:flutter/material.dart';

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
        return Icons.check;
      case CourseStatus.current:
        return Icons.radio_button_checked;
      case CourseStatus.unlocked:
        return Icons.radio_button_unchecked;
      case CourseStatus.locked:
        return Icons.lock_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = status == CourseStatus.locked;
    final body = Material(
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
            // Obligatorios: borde sólido normal. Electivos: sin borde (lo pinta el CustomPaint).
            border: course.isElective
                ? null
                : Border.all(color: status.borderColor, width: 2.5),
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
                    Expanded(
                      child: Text(
                        course.code,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
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
                    if (course.isExternal)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        child: Text(
                          course.externalFaculty!.substring(0, 3).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      )
                    else if (course.isElective)
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
                          'ELECT.',
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

    // Los electivos se envuelven en un CustomPaint que dibuja el borde discontinuo.
    if (!course.isElective) return body;
    return CustomPaint(
      painter: _DashedBorderPainter(color: status.borderColor),
      child: body,
    );
  }
}

// ── Painter del borde discontinuo ──────────────────────────────────────────────

class _DashedBorderPainter extends CustomPainter {
  final Color color;

  const _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 12.0;
    const strokeW = 2.5;
    const dashLen = 6.0;
    const gapLen = 4.0;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeW / 2,
        strokeW / 2,
        size.width - strokeW,
        size.height - strokeW,
      ),
      const Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      bool drawing = true;
      while (dist < metric.length) {
        final len = drawing ? dashLen : gapLen;
        if (drawing) {
          canvas.drawPath(
            metric.extractPath(dist, (dist + len).clamp(0, metric.length)),
            paint,
          );
        }
        dist += len;
        drawing = !drawing;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => color != old.color;
}
