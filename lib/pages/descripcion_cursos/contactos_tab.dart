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
          Text(
            'DOCENTE',
            style: TextStyle(
              color: colors.secondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (control.docenteContacto.value != null)
            ContactoCard(
              nombres: control.docenteContacto.value!.firstName,
              apellidos: control.docenteContacto.value!.lastName,
              rol: 'docente',
            ),
          const SizedBox(height: 22),
          Text(
            'ALUMNOS',
            style: TextStyle(
              color: colors.secondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...control.alumnosContacto.map((contacto) {
            final user = contacto.user;
            final role = contacto.roleInSection;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ContactoCard(
                nombres: user.firstName,
                apellidos: user.lastName,
                rol: role,
              ),
            );
          }),
        ],
      );
    });
  }
}
