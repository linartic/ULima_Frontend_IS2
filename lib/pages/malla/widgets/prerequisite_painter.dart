// lib/pages/malla/widgets/prerequisite_painter.dart
// Dibuja los conectores entre cursos y sus prerrequisitos.

import 'package:flutter/material.dart';

import '../../../models/malla_models.dart';
import '../malla_controller.dart';

class PrerequisitePainter extends CustomPainter {
  PrerequisitePainter({
    required this.courses,
    required this.statuses,
    required this.positions,
  });

  final List<CourseNode> courses;
  final Map<String, CourseStatus> statuses;
  final Map<String, Offset> positions;

  static const double _cardW = MallaController.cardWidth;
  static const double _cardH = MallaController.cardHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final approvedPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;
    final defaultPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (final c in courses) {
      for (final prereqId in c.coursePrerequisites) {
        final from = positions[prereqId];
        final to = positions[c.id];
        if (from == null || to == null) continue;

        final start = Offset(from.dx + _cardW, from.dy + _cardH / 2);
        final end = Offset(to.dx, to.dy + _cardH / 2);
        final paint = statuses[prereqId] == CourseStatus.approved
            ? approvedPaint
            : defaultPaint;

        final midX = (start.dx + end.dx) / 2;
        final path = Path()
          ..moveTo(start.dx, start.dy)
          ..lineTo(midX, start.dy)
          ..lineTo(midX, end.dy)
          ..lineTo(end.dx, end.dy);
        canvas.drawPath(path, paint);

        // Pequeña flecha
        const arrow = 6.0;
        final arrowPath = Path()
          ..moveTo(end.dx, end.dy)
          ..lineTo(end.dx - arrow, end.dy - arrow / 1.6)
          ..lineTo(end.dx - arrow, end.dy + arrow / 1.6)
          ..close();
        canvas.drawPath(arrowPath, Paint()..color = paint.color);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PrerequisitePainter old) {
    return old.statuses != statuses ||
        old.positions != positions ||
        old.courses != courses;
  }
}
