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
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: colors.onTertiaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant.withOpacity(0.6),
                    ),
                    children: [
                      TextSpan(text: "Peso: $peso%  •  "),
                      TextSpan(
                        text: "Nota: ${nota.toStringAsFixed(1)}/20",
                        style: TextStyle(
                          color: colors.primary,
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
            icon: Icon(Icons.delete_outline, color: colors.error, size: 22),
            onPressed: () {
              Get.defaultDialog(
                title: "Eliminar Nota",
                titleStyle: TextStyle(color: colors.onSurface),
                middleTextStyle: TextStyle(color: colors.onSurfaceVariant),
                backgroundColor: colors.surface,
                middleText: "¿Estás seguro de que quieres eliminar '$titulo'?",
                textConfirm: "Eliminar",
                textCancel: "Cancelar",
                confirmTextColor: colors.onError,
                buttonColor: colors.error,
                onConfirm: () {
                  onDelete();
                  print("✅ ÉXITO: Se eliminó la nota '$titulo' correctamente.");
                  Get.back();
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
