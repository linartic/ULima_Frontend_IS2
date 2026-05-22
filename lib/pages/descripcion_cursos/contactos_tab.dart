import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/descripcion_cursos/contacto_card.dart';

import 'descrip_cursos_controller.dart';

class ContactosTab extends StatelessWidget {
  final String idSeccion;
  final DescripCursosController control = Get.find();

  ContactosTab({super.key, required this.idSeccion});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Obx(() {
      return ListView(
        padding: const EdgeInsets.all(16),

        children: [
          // DOCENTE
          Text(
            'DOCENTE',

            style: TextStyle(
              color: colors.secondary,

              fontSize: 13,

              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          // Card docente
          if (control.docenteContacto.value != null)
            ContactoCard(
              nombre: control.docenteContacto.value!.fullName,
              rol: 'docente',
            ),

          const SizedBox(height: 22),

          // ALUMNOS
          Text(
            'ALUMNOS',

            style: TextStyle(
              color: colors.secondary,

              fontSize: 13,

              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          // Lista alumnos
          ...control.alumnosContacto.map((alumno) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),

              child: ContactoCard(nombre: alumno.fullName, rol: alumno.role),
            );
          }),
        ],
      );
    });
  }
}
