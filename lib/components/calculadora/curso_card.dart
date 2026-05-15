import 'package:flutter/material.dart';
import 'nota_tile.dart';

class CursoCard extends StatelessWidget {
  final Map curso;
  final double promedio;
  final double sumaPesos;
  final int cursoIndex;
  final Function(int, int) onDeleteNota;

  const CursoCard(
      {super.key, 
      required this.curso,
      required this.promedio,
      required this.sumaPesos,
      required this.cursoIndex,
      required this.onDeleteNota});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // Fondo gris muy claro para el cuerpo
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          // Header Naranja - Parte Superior
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE65100), // Naranja Ulima
              borderRadius: BorderRadius.circular(25),
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
                          Text(curso['id'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                          Text(curso['nombre'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                          Text("Ciclo: ${curso['ciclo']}",
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 11)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(promedio.toStringAsFixed(2),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold)),
                        const Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.white, size: 14),
                            Text(" Desaprobado",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11)),
                          ],
                        )
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 15),
                // Barra de pesos estilizada
                Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      // El progreso real
                      FractionallySizedBox(
                        widthFactor: (sumaPesos / 100).clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          "Suma de pesos: ${sumaPesos.toStringAsFixed(1)}% / 100%",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),

          // Cuerpo con las Notas (NotaTile)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: List.generate(curso['notas'].length, (index) {
                var nota = curso['notas'][index];
                return NotaTile(
                  titulo: nota['titulo'],
                  peso: nota['peso'],
                  nota: nota['valor'],
                  onDelete: () => onDeleteNota(cursoIndex, index),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
