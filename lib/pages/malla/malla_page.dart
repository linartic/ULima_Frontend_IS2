// lib/pages/malla/malla_page.dart
// Pantalla de Malla Curricular interactiva — grid 2D estilo mockup React.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../configs/themes.dart';
import '../../models/malla_models.dart';
import 'malla_controller.dart';
import 'widgets/course_card.dart';
import 'widgets/prerequisite_painter.dart';

class MallaPage extends StatelessWidget {
  const MallaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(MallaController());
    final colors = Theme.of(context).colorScheme;

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          _ProgressBar(controller: c, colors: colors),
          _ZoomToolbar(controller: c),
          Expanded(
            child: Obx(
              () => c.loading.value
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: MaterialTheme.primaryColor,
                      ),
                    )
                  : _MallaCanvas(controller: c),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Barra superior con contadores + progreso
// -----------------------------------------------------------------------------
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.controller, required this.colors});
  final MallaController controller;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: colors.outline.withValues(alpha: 0.5)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Chip(
                  color: CourseStatus.approved.color,
                  label: 'Finalizados',
                  count: controller.approvedCount,
                ),
                const SizedBox(width: 10),
                _Chip(
                  color: CourseStatus.current.color,
                  label: 'En proceso',
                  count: controller.currentCount,
                ),
                const SizedBox(width: 10),
                _Chip(
                  color: CourseStatus.unlocked.color,
                  label: 'Disponibles',
                  count: controller.unlockedCount,
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: controller.approvedRatio,
                minHeight: 6,
                backgroundColor: const Color(0xFFE2E8F0),
                color: MaterialTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Avance: ${controller.approvedCount} / ${controller.totalVisible} cursos',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.color, required this.label, required this.count});
  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count',
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
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

// -----------------------------------------------------------------------------
// Toolbar de zoom + reset
// -----------------------------------------------------------------------------
class _ZoomToolbar extends StatelessWidget {
  const _ZoomToolbar({required this.controller});
  final MallaController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          _IconBtn(icon: LucideIcons.zoomOut, onTap: controller.zoomOut),
          const SizedBox(width: 4),
          Obx(
            () => SizedBox(
              width: 56,
              child: Text(
                '${(controller.zoom.value * 100).round()}%',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          _IconBtn(icon: LucideIcons.zoomIn, onTap: controller.zoomIn),
          const SizedBox(width: 4),
          _IconBtn(icon: LucideIcons.locateFixed, onTap: controller.resetZoom),
          const Spacer(),
          _LegendDot(color: CourseStatus.approved.color, label: 'Apr.'),
          const SizedBox(width: 8),
          _LegendDot(color: CourseStatus.current.color, label: 'Cur.'),
          const SizedBox(width: 8),
          _LegendDot(color: CourseStatus.unlocked.color, label: 'Disp.'),
          const SizedBox(width: 8),
          _LegendDot(color: CourseStatus.locked.color, label: 'Bloq.'),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Center(
            child: Icon(icon, size: 18, color: const Color(0xFF334155)),
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Lienzo principal — InteractiveViewer + CustomPaint + cards posicionadas
// -----------------------------------------------------------------------------
class _MallaCanvas extends StatelessWidget {
  const _MallaCanvas({required this.controller});
  final MallaController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cards = controller.cards;
      final statuses = controller.statuses;
      final size = controller.canvasSize();
      final positions = <String, Offset>{
        for (final c in cards) c.id: controller.positionFor(c),
      };
      final zoom = controller.zoom.value;

      return InteractiveViewer(
        constrained: false,
        minScale: 0.5,
        maxScale: 1.6,
        scaleEnabled: true,
        panEnabled: true,
        boundaryMargin: const EdgeInsets.all(200),
        // Aplicamos un zoom inicial vía Transform en el contenido, manteniendo el
        // pan/zoom táctil del InteractiveViewer.
        child: Transform.scale(
          scale: zoom,
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Stack(
              children: [
                // Etiquetas de columna (NIVEL 1, NIVEL 2, ...).
                ..._levelHeaders(cards),
                // Conectores entre prerrequisitos.
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: PrerequisitePainter(
                        courses: cards,
                        statuses: statuses,
                        positions: positions,
                      ),
                    ),
                  ),
                ),
                // Cards interactivas.
                for (final c in cards)
                  Positioned(
                    left: positions[c.id]!.dx,
                    top:
                        positions[c.id]!.dy +
                        32, // 32 = espacio del header de nivel
                    child: CourseCard(
                      course: c,
                      status: statuses[c.id] ?? CourseStatus.locked,
                      onTap: () => _openDetails(context, c, statuses),
                      onLongPress: () => controller.cycleStatus(c.id),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  List<Widget> _levelHeaders(List<CourseNode> cards) {
    if (cards.isEmpty) return const [];
    final levels = cards.map((c) => c.level).toSet().toList()..sort();
    final result = <Widget>[];
    for (final lvl in levels) {
      final x =
          MallaController.padding +
          (lvl - 1) * (MallaController.cardWidth + MallaController.columnGap);
      result.add(
        Positioned(
          left: x,
          top: MallaController.padding,
          child: SizedBox(
            width: MallaController.cardWidth,
            height: 26,
            child: Center(
              child: Text(
                'NIVEL $lvl',
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return result;
  }

  void _openDetails(
    BuildContext context,
    CourseNode course,
    Map<String, CourseStatus> statuses,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _CourseDetailSheet(course: course, statuses: statuses),
    );
  }
}

class _CourseDetailSheet extends StatelessWidget {
  const _CourseDetailSheet({required this.course, required this.statuses});
  final CourseNode course;
  final Map<String, CourseStatus> statuses;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MallaController>();
    final currentStatus = statuses[course.id] ?? CourseStatus.locked;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: currentStatus.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  course.code,
                  style: TextStyle(
                    color: currentStatus.borderColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _PillStatus(status: currentStatus),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            course.name,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _InfoTag(icon: LucideIcons.layers, text: 'Nivel ${course.level}'),
              _InfoTag(
                icon: LucideIcons.award,
                text: '${course.credits} créditos',
              ),
              if (course.isElective)
                const _InfoTag(icon: LucideIcons.bookmark, text: 'Electivo'),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Prerrequisitos',
            style: TextStyle(
              color: Color(0xFF334155),
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          _PrereqList(course: course, statuses: statuses),
          if (course.isElective && course.specialties.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Forma parte de los diplomas',
              style: TextStyle(
                color: Color(0xFF334155),
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: course.specialties
                  .map(
                    (s) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE8DC),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        s,
                        style: const TextStyle(
                          color: MaterialTheme.primaryDark,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 18),
          if (currentStatus != CourseStatus.locked)
            ElevatedButton.icon(
              onPressed: () {
                controller.cycleStatus(course.id);
                Navigator.pop(context);
              },
              icon: const Icon(LucideIcons.repeat, size: 18),
              label: Text(_nextStatusLabel(currentStatus)),
              style: ElevatedButton.styleFrom(
                backgroundColor: MaterialTheme.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.lock, size: 16, color: Color(0xFF64748B)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Este curso está bloqueado hasta que cumplas sus prerrequisitos.',
                      style: TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _nextStatusLabel(CourseStatus s) {
    switch (s) {
      case CourseStatus.unlocked:
        return 'Marcar como cursando';
      case CourseStatus.current:
        return 'Marcar como aprobado';
      case CourseStatus.approved:
        return 'Volver a disponible';
      case CourseStatus.locked:
        return 'No disponible';
    }
  }
}

class _PrereqList extends StatelessWidget {
  const _PrereqList({required this.course, required this.statuses});
  final CourseNode course;
  final Map<String, CourseStatus> statuses;

  @override
  Widget build(BuildContext context) {
    final mallaService = Get.find<MallaController>();
    final byId = {for (final c in mallaService.cards) c.id: c};

    final concrete = course.coursePrerequisites;
    final cycleReq = course.requiredCompletedLevel;
    final cycleReqOk = cycleReq == null
        ? false
        : mallaService.hasCompletedMandatoryCycles(cycleReq, statuses);

    if (concrete.isEmpty && cycleReq == null) {
      return const Text(
        'Este curso no tiene prerrequisitos.',
        style: TextStyle(
          color: Color(0xFF64748B),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Column(
      children: [
        if (cycleReq != null)
          _PrereqRow(
            label:
                'Haber culminado hasta el ciclo $cycleReq (solo obligatorios)',
            ok: cycleReqOk,
            icon: cycleReqOk ? LucideIcons.flag : LucideIcons.circleSlash,
          ),
        ...concrete.map((p) {
          final c = byId[p];
          final ok = statuses[p] == CourseStatus.approved;
          return _PrereqRow(
            label: c?.name ?? p,
            ok: ok,
            icon: ok ? LucideIcons.checkCheck : LucideIcons.circleSlash,
          );
        }),
      ],
    );
  }
}

class _PrereqRow extends StatelessWidget {
  const _PrereqRow({required this.label, required this.ok, required this.icon});
  final String label;
  final bool ok;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final color = ok ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  const _InfoTag({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF334155)),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillStatus extends StatelessWidget {
  const _PillStatus({required this.status});
  final CourseStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: status.borderColor.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.borderColor,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
