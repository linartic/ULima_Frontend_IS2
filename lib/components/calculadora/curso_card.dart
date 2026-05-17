import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'nota_tile.dart';

class CursoCard extends StatelessWidget {
  final Map curso;
  final double promedio;
  final double sumaPesos;
  final int cursoIndex;
  final Function(int, int) onDeleteNota;

  const CursoCard({
    super.key, 
    required this.curso,
    required this.promedio,
    required this.sumaPesos,
    required this.cursoIndex,
    required this.onDeleteNota,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color:  colors.onSecondary, 
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          // Header Naranja - Parte Superior
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.primaryContainer, 
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            curso['seccion'] ?? 'Sin sección', 
                            style: TextStyle(
                              color: colors.onPrimary, 
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            curso['nombre'],
                            style: TextStyle(
                              color: colors.onPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Ciclo: ${curso['ciclo']}",
                            style: TextStyle(
                              color: colors.onPrimary.withOpacity(0.8),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          promedio.toStringAsFixed(2),
                          style: TextStyle(
                            color: colors.onPrimary,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (promedio < 11.0)
                          Row(
                            children: [
                              Icon(Icons.error_outline, color: colors.onPrimary, size: 14),
                              Text(
                                " Desaprobado",
                                style: TextStyle(color: colors.onPrimary, fontSize: 11),
                              ),
                            ],
                          ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 15),
                
                Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: colors.shadow.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        widthFactor: (sumaPesos / 100).clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: colors.secondary.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          "Suma de pesos: ${sumaPesos.toStringAsFixed(1)}% / 100%",
                          style: TextStyle(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Obx(() {
              final listasNotas = curso['notas'] as List;
              return Column(
                children: List.generate(listasNotas.length, (index) {
                  final nota = listasNotas[index];
                  return NotaTile(
                    titulo: nota['titulo'],
                    peso: nota['peso'],
                    nota: nota['valor'],
                    onDelete: () => onDeleteNota(cursoIndex, index),
                  );
                }),
              );
            }),
          ),
        ],
      ),
    );
  }
}