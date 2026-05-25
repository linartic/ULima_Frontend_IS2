import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ulima_plus/pages/descripcion_cursos/descrip_cursos_controller.dart';

import '../../components/descripcion_cursos/anuncio_card.dart';

class AnunciosTab extends StatelessWidget {
  final String idSeccion;
  final DescripCursosController control = Get.find();

  AnunciosTab({super.key, required this.idSeccion});

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      if (control.anuncios.isEmpty) {
        return const Center(child: Text('No hay anuncios'));
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: ListView.builder(
          itemCount: control.anuncios.length,
          itemBuilder: (context, index) {
            final anuncio = control.anuncios[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CardAnuncio(
                titulo: anuncio.titulo,
                descripcion: anuncio.mensaje,
                autor: '${anuncio.autor.fullName} - ${anuncio.autor.role}',
                fecha: anuncio.fecha,
              ),
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }
}
