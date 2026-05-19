// lib/pages/descripCursos/asesorias_tab.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/descripcion_cursos/asesoria_card.dart';
import 'descrip_cursos_controller.dart';

class AsesoriasTab extends StatelessWidget {

  // Controller del módulo
  final DescripCursosController
      control =
          Get.find();

  AsesoriasTab({
    super.key,
  });

  Widget _buildBody(BuildContext context) {

    return Obx(() {
        // Si no hay asesorías
        if (control.asesorias.isEmpty) {

          return const Center(
            child: Text(
              'No hay asesorías',
            ),
          );
        }

        // Lista de cards
        return Padding(

          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),

          child: ListView.builder(
            itemCount: control.asesorias.length,

            itemBuilder: (context, index) {
              final asesoria =
                  control.asesorias[index];

              return Padding(

                padding:
                    const EdgeInsets.only(
                  bottom: 12,
                ),

                child: CardAsesoria(

                  // Enviamos la asesoría
                  asesoria: asesoria,
                ),
              );
            },
          ),
        );
      });
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    return _buildBody(context);
  }
}