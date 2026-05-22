import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/anuncio_model.dart';

class AnuncioService {
  Future<List<Anuncio>> fetchAnuncios(String idSeccion) async {
    try {
      final String response = await rootBundle.loadString('assets/data/anuncios.json');

      final data = json.decode(response);
      final List<dynamic> anunciosRaw = data['anuncios'] ?? [];

      final todosLosAnuncios = anunciosRaw.map((a) => Anuncio.fromJson(a)).toList();

      return todosLosAnuncios.where((anuncio) => anuncio.cursoId == idSeccion).toList();
      
    } catch (e) {
      print("Error cargando anuncios: $e");
      return []; 
    }
  }
}