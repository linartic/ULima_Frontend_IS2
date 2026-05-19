import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/anuncio_model.dart';

class AnuncioService {

  // Obtiene anuncios desde el JSON
  Future<List<Anuncio>>
      fetchAnuncios() async {

    // Carga el archivo JSON
    final String response =
        await rootBundle.loadString(
      'assets/data/anuncios.json',
    );

    // Convierte el JSON
    final data =
        json.decode(response);

    // Obtiene la lista de anuncios
    final List anuncios =
        data['anuncios'];

    // Convierte cada anuncio
    // a AnuncioModel
    return anuncios
        .map(
          (a) =>
              Anuncio.fromJson(a),
        )
        .toList();
  }
}