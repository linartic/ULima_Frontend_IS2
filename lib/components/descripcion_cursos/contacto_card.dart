import 'package:flutter/material.dart';

class ContactoCard
    extends StatelessWidget {

  final String nombre;
  final String rol;

  const ContactoCard({
    super.key,
    required this.nombre,
    required this.rol,
  });

  @override
  Widget build(
    BuildContext context,
  ) {

    final colors =
        Theme.of(context)
            .colorScheme;

    // Inicial nombre
    final inicial = nombre.split(' ')[1][0].toUpperCase();

    return Container(

      width: double.infinity,


      decoration: BoxDecoration(

        color: colors.surface,

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: colors.outline,
          width: 0.5,
        ),
      ),

      child: Row(

        children: [

          // Avatar
          Container(

            width: 50,
            height: 50,

            decoration: BoxDecoration(
              color:
                  colors.surfaceContainerHighest,

              shape:
                  BoxShape.circle,
            ),

            child: Center(

              child: Text(

                inicial,

                style: TextStyle(

                  color:
                      colors.onSurface,

                  fontSize: 20,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 5),

          // Información
          Expanded(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [

                // Nombre
                Text(

                  nombre.toUpperCase(), //

                  style: TextStyle(

                    color:
                        colors.onSurface,

                    fontSize: 16,
                  ),
                ),

                // Rol
                if (
                    rol ==
                        'delegado' ||
                    rol ==
                        'subdelegado'
                )

                  Padding(

                    padding:
                        const EdgeInsets.only(
                      top: 0,
                    ),

                    child: Text(

                      rol == 'delegado'
                          ? 'Delegado'
                          : 'Subdelegado',

                      style: const TextStyle(

                        color:
                            Color.fromARGB(
                              255,
                              255,
                              119,
                              65,
                            ),

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