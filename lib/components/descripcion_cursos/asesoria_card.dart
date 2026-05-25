import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/asesoria_model.dart';

class CardAsesoria extends StatefulWidget {
  final Asesoria asesoria;

  const CardAsesoria({super.key, required this.asesoria});

  @override
  State<CardAsesoria> createState() => _CardAsesoriaState();
}

class _CardAsesoriaState extends State<CardAsesoria> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              expanded = !expanded;
            });
          },

          borderRadius: BorderRadius.circular(16),

          child: Container(
            width: double.infinity,

            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.outline, width: 0.5),
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      '${widget.asesoria.dia} ${widget.asesoria.inicio} - ${widget.asesoria.fin}',

                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                Text(
                  expanded ? '▲' : '▼',

                  style: TextStyle(color: colors.primary, fontSize: 16),
                ),
              ],
            ),
          ),
        ),

        if (expanded)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outline),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _info(context, 'Docente', widget.asesoria.docente.fullName),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          _info(context, 'Aula', widget.asesoria.aula),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,

                        children: [
                          Text(
                            'Zoom',

                            style: TextStyle(
                              color: colors.secondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),

                          GestureDetector(
                            onTap: () async {
                              final Uri url = Uri.parse(widget.asesoria.zoom);

                              await launchUrl(
                                url,

                                mode: LaunchMode.externalApplication,
                              );
                            },

                            child: const Text(
                              'Acceder a la sala',
                              style: TextStyle(
                                color: Color.fromARGB(255, 33, 89, 243),
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: Color.fromARGB(
                                  255,
                                  33,
                                  89,
                                  243,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _info(BuildContext context, String title, String value) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(title, style: TextStyle(color: colors.secondary, fontSize: 12)),

        const SizedBox(height: 4),

        Text(
          value,

          style: TextStyle(color: colors.onSurface.withValues(alpha: 0.9)),
        ),
      ],
    );
  }
}
