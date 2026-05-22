// lib/pages/descripCursos/anuncios_tab.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ulima_plus/pages/descripcion_cursos/descrip_cursos_controller.dart';

import '../../components/descripcion_cursos/anuncio_card.dart';

class AnunciosTab extends StatelessWidget {
  final String idSeccion;
  // Controller principal
  final DescripCursosController control = Get.find();

  AnunciosTab({super.key, required this.idSeccion});

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      // Si no hay anuncios
      if (control.anuncios.isEmpty) {
        return const Center(child: Text('No hay anuncios'));
      }

      // Lista de anuncios
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),

        child: ListView.builder(
          // Cantidad de anuncios
          itemCount: control.anuncios.length,

          itemBuilder: (context, index) {
            // Anuncio actual
            final anuncio = control.anuncios[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),

              child: CardAnuncio(
                titulo: anuncio.titulo,
                // Mensaje
                descripcion: anuncio.mensaje,
                // Nombre + rol
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
