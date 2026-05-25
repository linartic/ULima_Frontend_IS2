import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/docente_model.dart';

class DocenteService {
  Future<List<Docente>> fetchDocentes() async {
    final String response = await rootBundle.loadString(
      'assets/data/docentes.json',
    );

    final data = json.decode(response);
    final List docentes = data['docentes'];

    return docentes.map((d) => Docente.fromJson(d)).toList();
  }

  Future<Docente?> findDocenteByCode(String code) async {
    final docentes = await fetchDocentes();

    try {
      return docentes.firstWhere((d) => d.code == code);
    } catch (e) {
      return null;
    }
  }
}
