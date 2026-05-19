import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/seccion_model.dart';

class SeccionService {

  // Obtiene secciones
  Future<List<Seccion>>
      fetchSecciones() async {

    // Carga JSON
    final String response =
        await rootBundle.loadString(
      'assets/data/secciones.json',
    );

    // Convierte JSON
    final data =
        json.decode(response);

    // Obtiene lista
    final List secciones =
        data['secciones'];

    // Convierte a models
    return secciones
        .map(
          (s) =>
              Seccion.fromJson(s),
        )
        .toList();
  }
}