import 'package:flutter/material.dart';

class CardAnuncio extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final String autor;
  final String fecha;

  const CardAnuncio({
    super.key,
    required this.titulo,
    required this.descripcion,
    required this.autor,
    required this.fecha,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline, width: 0.5),
      ),

      margin: const EdgeInsets.only(bottom: 12),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              titulo,

              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(descripcion),

            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Expanded(
                  child: Text(
                    autor,

                    style: TextStyle(color: colors.primary, fontSize: 12),
                  ),
                ),

                Text(
                  fecha,

                  style: TextStyle(color: colors.secondary, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
