// lib/pages/malla/malla_page.dart
// Malla curricular con dos piscinas: obligatorios (arriba) y electivos (abajo).

import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

// ── Barra de progreso ──────────────────────────────────────────────────────────
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

// ── Toolbar de zoom ────────────────────────────────────────────────────────────
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
          _IconBtn(icon: Icons.zoom_out, onTap: controller.zoomOut),
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
          _IconBtn(icon: Icons.zoom_in, onTap: controller.zoomIn),
          const SizedBox(width: 4),
          _IconBtn(
            icon: Icons.center_focus_strong,
            onTap: controller.resetZoom,
          ),
          const Spacer(),
          // Leyenda: línea sólida = obligatorio, línea discontinua = electivo
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18,
                height: 2.5,
                decoration: BoxDecoration(
                  color: const Color(0xFF64748B),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'Obligatorio',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF64748B),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Container(
                    width: 5,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF64748B),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Container(
                    width: 5,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF64748B),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 5),
              const Text(
                'Electivo',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
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

// ── Canvas principal ───────────────────────────────────────────────────────────
class _MallaCanvas extends StatelessWidget {
  const _MallaCanvas({required this.controller});
  final MallaController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final mandatory = controller.mandatoryCards;
      final electives = controller.electiveCards;
      final allCards = controller.cards;
      final statuses = controller.statuses;
      final size = controller.canvasSize();
      final zoom = controller.zoom.value;

      // Posiciones absolutas de todas las cards (obligatorios + electivos).
      final positions = <String, Offset>{
        for (final c in allCards) c.id: controller.positionFor(c),
      };

      return InteractiveViewer(
        constrained: false,
        minScale: 0.5,
        maxScale: 1.6,
        scaleEnabled: true,
        panEnabled: true,
        boundaryMargin: const EdgeInsets.all(200),
        child: Transform.scale(
          scale: zoom,
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Stack(
              children: [
                // ── Etiqueta sección obligatorios ─────────────────────────────
                Positioned(
                  left: MallaController.padding,
                  top: MallaController.padding,
                  child: const _SectionLabel(
                    icon: Icons.menu_book_outlined,
                    text: 'OBLIGATORIOS',
                  ),
                ),

                // ── Cabeceras de nivel — piscina obligatoria ──────────────────
                ..._levelHeaders(
                  mandatory,
                  yOffset:
                      MallaController.padding +
                      MallaController.sectionLabelHeight,
                ),

                // ── Separador entre piscinas ──────────────────────────────────
                if (electives.isNotEmpty)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: controller.separatorY - 18,
                    child: _PoolDivider(
                      width: size.width,
                      separatorY: controller.separatorY,
                    ),
                  ),

                // ── Etiqueta sección electivos ────────────────────────────────
                if (electives.isNotEmpty)
                  Positioned(
                    left: MallaController.padding,
                    top:
                        controller.electiveSectionY -
                        MallaController.sectionLabelHeight,
                    child: const _SectionLabel(
                      icon: Icons.bookmark_border,
                      text: 'ELECTIVOS',
                    ),
                  ),

                // ── Cabeceras de nivel — piscina electiva ─────────────────────
                if (electives.isNotEmpty)
                  ..._levelHeaders(
                    electives,
                    yOffset: controller.electiveSectionY,
                  ),

                // ── Conectores de prerrequisitos ──────────────────────────────
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: PrerequisitePainter(
                        courses: allCards,
                        statuses: statuses,
                        positions: positions,
                      ),
                    ),
                  ),
                ),

                // ── Cards obligatorias ────────────────────────────────────────
                for (final c in mandatory)
                  Positioned(
                    left: positions[c.id]!.dx,
                    top: positions[c.id]!.dy,
                    child: CourseCard(
                      course: c,
                      status: statuses[c.id] ?? CourseStatus.locked,
                      onTap: () => _openDetails(context, c, statuses),
                      onLongPress: () => controller.cycleStatus(c.id),
                    ),
                  ),

                // ── Cards electivas ───────────────────────────────────────────
                for (final c in electives)
                  Positioned(
                    left: positions[c.id]!.dx,
                    top: positions[c.id]!.dy,
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

  List<Widget> _levelHeaders(
    List<CourseNode> cards, {
    required double yOffset,
  }) {
    if (cards.isEmpty) return const [];
    final levels = cards.map((c) => c.level).toSet().toList()..sort();
    return [
      for (final lvl in levels)
        Positioned(
          left:
              MallaController.padding +
              (lvl - 1) *
                  (MallaController.cardWidth + MallaController.columnGap),
          top: yOffset,
          child: SizedBox(
            width: MallaController.cardWidth,
            height: MallaController.levelHeaderHeight,
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
    ];
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

// ── Separador visual entre piscinas ───────────────────────────────────────────
class _PoolDivider extends StatelessWidget {
  const _PoolDivider({required this.width, required this.separatorY});
  final double width;
  final double separatorY;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 36,
      child: Row(
        children: [
          const SizedBox(width: MallaController.padding),
          Expanded(
            child: Container(
              height: 1.5,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0x00CBD5E1),
                    Color(0xFFCBD5E1),
                    Color(0x00CBD5E1),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: MallaController.padding),
        ],
      ),
    );
  }
}

// ── Label de sección ───────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF64748B)),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}

// ── Detail sheet ───────────────────────────────────────────────────────────────
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
              if (course.isExternal) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    course.externalFaculty!,
                    style: const TextStyle(
                      color: Color(0xFF4B5563),
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
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
              _InfoTag(
                icon: Icons.layers_outlined,
                text: 'Nivel ${course.level}',
              ),
              _InfoTag(
                icon: Icons.workspace_premium_outlined,
                text: '${course.credits} créditos',
              ),
              if (course.isElective)
                const _InfoTag(icon: Icons.bookmark_border, text: 'Electivo'),
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
              icon: const Icon(Icons.repeat, size: 18),
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
                  Icon(Icons.lock_outline, size: 16, color: Color(0xFF64748B)),
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
    final mallaController = Get.find<MallaController>();
    final byId = {for (final c in mallaController.cards) c.id: c};
    final concrete = course.coursePrerequisites;
    final cycleReq = course.requiredCompletedLevel;
    final cycleReqOk = cycleReq == null
        ? false
        : mallaController.hasCompletedMandatoryCycles(cycleReq, statuses);

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
                'Haber aprobado todos los obligatorios hasta el nivel $cycleReq',
            ok: cycleReqOk,
            icon: cycleReqOk ? Icons.flag_outlined : Icons.block,
          ),
        ...concrete.map((p) {
          final c = byId[p];
          final ok = statuses[p] == CourseStatus.approved;
          return _PrereqRow(
            label: c?.name ?? p,
            ok: ok,
            icon: ok ? Icons.done_all : Icons.block,
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
