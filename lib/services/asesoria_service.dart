import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/asesoria_model.dart';

class AsesoriaService {

  Future<List<Asesoria>>
      fetchAsesorias(String idSeccion) async {

    final String response =
        await rootBundle.loadString(
      'assets/data/asesorias.json',
    );

    final data =
        json.decode(response);

    final List asesorias =
        data['asesorias'];

    return asesorias
        .map(
          (a) =>
              Asesoria.fromJson(a),
        )
        .toList();
  }
}