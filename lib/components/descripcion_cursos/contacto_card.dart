import 'package:flutter/material.dart';

class ContactoCard extends StatelessWidget {
  final String nombres;
  final String apellidos;
  final String rol;

  const ContactoCard({
    super.key,
    required this.nombres,
    required this.apellidos,
    required this.rol,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final inicial = nombres[0].toUpperCase();

    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: colors.surface,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: colors.outline, width: 0.5),
      ),

      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,

            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,

              shape: BoxShape.circle,
            ),

            child: Center(
              child: Text(
                inicial,

                style: TextStyle(
                  color: colors.onSurface,

                  fontSize: 20,

                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Text(
                  '${apellidos.toUpperCase()}, ${nombres.toUpperCase()}',

                  style: TextStyle(color: colors.onSurface, fontSize: 16),
                ),

                if (rol == 'delegado' || rol == 'subdelegado')
                  Padding(
                    padding: const EdgeInsets.only(top: 0),

                    child: Text(
                      rol == 'delegado' ? 'Delegado' : 'Subdelegado',

                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 119, 65),

                        fontSize: 12,
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
}
