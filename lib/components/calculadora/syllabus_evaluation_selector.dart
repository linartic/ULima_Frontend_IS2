import 'package:flutter/material.dart';
import '../../models/evaluation_model.dart';

/// Widget que muestra las evaluaciones disponibles del sílabo de un curso
/// Permite al usuario seleccionar una evaluación para registrar su nota
class SyllabusEvaluationSelector extends StatelessWidget {
  final CourseSyllabus syllabus;
  final Function(EvaluationComponent) onEvaluationSelected;
  final Color primaryColor;

  const SyllabusEvaluationSelector({
    super.key,
    required this.syllabus,
    required this.onEvaluationSelected,
    required this.primaryColor,
  });

  /// Retorna el icono según el tipo de evaluación
  IconData _getIconForType(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'practica':
        return Icons.assignment;
      case 'examen':
        return Icons.school;
      case 'trabajo':
        return Icons.work;
      case 'participacion':
        return Icons.people;
      case 'quiz':
        return Icons.quiz;
      default:
        return Icons.check_circle;
    }
  }

  /// Retorna el color según el tipo de evaluación
  Color _getColorForType(String tipo, ThemeData theme) {
    switch (tipo.toLowerCase()) {
      case 'practica':
        return Colors.blue;
      case 'examen':
        return Colors.red;
      case 'trabajo':
        return Colors.green;
      case 'participacion':
        return Colors.purple;
      case 'quiz':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del sílabo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.book, color: primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Evaluaciones del Sílabo',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        'Peso total: ${syllabus.pesoTotal.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: primaryColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Lista de evaluaciones
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: syllabus.evaluaciones.map((evaluacion) {
                final typeColor = _getColorForType(evaluacion.tipo, Theme.of(context));
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onEvaluationSelected(evaluacion),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: typeColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getIconForType(evaluacion.tipo),
                                color: typeColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        evaluacion.sigla,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: typeColor,
                                        ),
                                      ),
                                      Text(
                                        '${evaluacion.peso.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: colors.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    evaluacion.nombre,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.add_circle_outline,
                              color: primaryColor,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
