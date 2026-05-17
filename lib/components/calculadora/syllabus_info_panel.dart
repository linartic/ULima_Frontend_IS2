import 'package:flutter/material.dart';
import '../../models/evaluation_model.dart';

/// Panel informativo que muestra un resumen de las evaluaciones del sílabo
class SyllabusInfoPanel extends StatelessWidget {
  final CourseSyllabus syllabus;
  final Color primaryColor;

  const SyllabusInfoPanel({
    super.key,
    required this.syllabus,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Agrupar evaluaciones por tipo
    final evaluacionesPorTipo = <String, List<EvaluationComponent>>{};
    for (var eval in syllabus.evaluaciones) {
      if (!evaluacionesPorTipo.containsKey(eval.tipo)) {
        evaluacionesPorTipo[eval.tipo] = [];
      }
      evaluacionesPorTipo[eval.tipo]!.add(eval);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.assignment_ind, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Componentes del Sílabo',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${syllabus.pesoTotal.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Grid de evaluaciones resumidas
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: syllabus.evaluaciones.map((eval) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border.all(color: colors.outline.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      eval.sigla,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${eval.peso.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 10,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
