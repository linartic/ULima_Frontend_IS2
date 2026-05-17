// lib/pages/descripCursos/descrip_cursos.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/seccion_model.dart';

import 'anuncios_tab.dart';
import 'asesoria_tab.dart';
import 'contactos_tab.dart';

import 'descrip_cursos_controller.dart';

class DescripCursos extends StatelessWidget {
  DescripCursos({super.key});

  final DescripCursosController control = Get.put(DescripCursosController());

  Widget _courseTitle(BuildContext context, Seccion seccion) {
    ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      color: colors.primary,

      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),

      child: Stack(
        alignment: Alignment.center,

        children: [
          Center(
            child: Text(
              seccion.curso,

              style: TextStyle(
                color: colors.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

          Align(
            alignment: Alignment.centerLeft,

            child: InkWell(
              onTap: () {
                Get.back();
              },

              child: Icon(Icons.arrow_back, color: colors.onPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, Seccion seccion) {
    ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,

      color: colors.primaryContainer,

      padding: const EdgeInsets.symmetric(vertical: 10),

      child: Center(child: Text('Sección: ${seccion.codigo}')),
    );
  }

  Widget _asistencia(BuildContext context, Seccion seccion) {
    ColorScheme colors = Theme.of(context).colorScheme;

    int presentes = seccion.presentes;

    int ausentes = seccion.ausentes;

    int total = seccion.total;

    double porcentaje = presentes / total;

    return Container(
      width: double.infinity,

      color: colors.secondaryContainer,

      padding: const EdgeInsets.all(20),

      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Asistencia',

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        const Text(
                          '✓',

                          style: TextStyle(color: Colors.green, fontSize: 22),
                        ),

                        const SizedBox(width: 16),

                        Text('$presentes horas'),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Text(
                          '✗',

                          style: TextStyle(color: Colors.red, fontSize: 22),
                        ),

                        const SizedBox(width: 16),

                        Text('$ausentes horas'),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Container(height: 1, color: Colors.black26),

                    const SizedBox(height: 14),

                    Padding(
                      padding: const EdgeInsets.only(left: 38),

                      child: Text(
                        '$total horas',

                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: 120,
                height: 120,

                child: Stack(
                  alignment: Alignment.center,

                  children: [
                    SizedBox(
                      width: 90,
                      height: 90,

                      child: CircularProgressIndicator(
                        value: porcentaje,

                        strokeWidth: 16,

                        backgroundColor: Colors.red,

                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.green,
                        ),
                      ),
                    ),

                    Container(
                      width: 48,
                      height: 48,

                      decoration: BoxDecoration(
                        color: colors.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required int index,
  }) {
    ColorScheme colors = Theme.of(context).colorScheme;

    return Obx(() {
      bool isSelected = control.selectedTab.value == index;

      return Expanded(
        child: InkWell(
          onTap: () {
            control.selectedTab.value = index;
          },

          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),

            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected ? colors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                Icon(
                  icon,
                  size: 22,

                  color: isSelected ? colors.primary : Colors.grey,
                ),

                const SizedBox(height: 4),

                Text(
                  text,

                  style: TextStyle(
                    fontSize: 12,

                    color: isSelected ? colors.primary : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _tabs(BuildContext context) {
    return Row(
      children: [
        _tabItem(
          context: context,
          icon: Icons.notifications_none,
          text: 'Anuncios',
          index: 0,
        ),

        _tabItem(
          context: context,
          icon: Icons.bookmark_border,
          text: 'Asesorías',
          index: 1,
        ),

        _tabItem(
          context: context,
          icon: Icons.people_outline,
          text: 'Contactos',
          index: 2,
        ),
      ],
    );
  }

  Widget _selectedPage(Seccion seccion) {
    return Obx(() {
      switch (control.selectedTab.value) {
        case 0:
          return AnunciosTab(
            anuncios: seccion.anuncios,
            delegadoNombre:
                '${seccion.delegado.nombre} - ${seccion.delegado.rol}',
          );

        case 1:
          return const AsesoriasTab();

        case 2:
          return const ContactosTab();

        default:
          return AnunciosTab(
            anuncios: seccion.anuncios,
            delegadoNombre:
                '${seccion.delegado.nombre} - ${seccion.delegado.rol}',
          );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (control.secciones.isEmpty) {
        return const SizedBox();
      }

      final seccion = control.secciones.first;

      return Column(
        children: [
          _courseTitle(context, seccion),

          _section(context, seccion),

          _asistencia(context, seccion),

          _tabs(context),

          Expanded(child: _selectedPage(seccion)),
        ],
      );
    });
  }
}
