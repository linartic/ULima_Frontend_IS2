import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotaTile extends StatelessWidget {
  final String titulo;
  final int peso;
  final double nota;
  final VoidCallback onDelete;

  const NotaTile({
    super.key,
    required this.titulo,
    required this.peso,
    required this.nota,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 245, 244, 244),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    children: [
                      TextSpan(text: "Peso: $peso%  •  "),
                      TextSpan(
                        text: "Nota: ${nota.toStringAsFixed(1)}/20",
                        style: const TextStyle(
                          color: Color(0xFF00BFA5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red.shade300,
              size: 22,
            ),
            onPressed: () {
              Get.defaultDialog(
                title: "Eliminar Nota",
                middleText: "¿Estás seguro de que quieres eliminar '$titulo'?",
                textConfirm: "Eliminar",
                textCancel: "Cancelar",
                confirmTextColor: Colors.white,
                buttonColor: Colors.red.shade400,
                onConfirm: () {
                  onDelete();
                  print("✅ ÉXITO: Se eliminó la nota '$titulo' correctamente."); // Ejecuta la eliminación real
                  Get.back(); // Cierra el diálogo
                },
              );
            },
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
