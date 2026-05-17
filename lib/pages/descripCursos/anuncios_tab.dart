import 'package:flutter/material.dart';

import '../../../components/infoCursos/card_anuncio.dart';
import '../../models/anuncio_model.dart';

class AnunciosTab extends StatelessWidget {
  final List<Anuncio> anuncios;
  final String delegadoNombre;

  const AnunciosTab({
    super.key,
    required this.anuncios,
    required this.delegadoNombre,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),

      itemCount: anuncios.length,

      itemBuilder: (context, index) {
        final anuncio = anuncios[index];

        return CardAnuncio(
          titulo: anuncio.titulo,
          descripcion: anuncio.mensaje,
          profesor: delegadoNombre,
          fecha: anuncio.fecha,
        );
      },
    );
  }
}
