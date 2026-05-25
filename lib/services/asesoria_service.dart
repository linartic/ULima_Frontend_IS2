import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ulima_plus/services/docente_service.dart';
import 'package:ulima_plus/services/seccion_service.dart';
import '../models/asesoria_model.dart';

class AsesoriaService {
  final DocenteService _docenteService = DocenteService();
  final SeccionService _sectionService = SeccionService();

  Future<List<Asesoria>> fetchAsesorias(String idSeccion) async {
    try {
      final seccion = await _sectionService.findSectionById(idSeccion);
      if (seccion == null) {
        return [];
      }

      final String response = await rootBundle.loadString(
        'assets/data/asesorias.json',
      );

      final data = json.decode(response);
      final List<dynamic> asesoriasRaw = data['asesorias'] ?? [];

      final filtradas = asesoriasRaw.where((a) {
        final mismoCurso = a['courseId'].toString() == seccion.idCurso;
        final mismoDocente = a['docenteCode'].toString() == seccion.docenteCode;

        return mismoCurso && mismoDocente;
      }).toList();

      final List<Asesoria> asesorias = [];

      for (final a in filtradas) {
        final asesoriaJson = a as Map<String, dynamic>;
        final docente = await _docenteService.findDocenteByCode(
          asesoriaJson['docenteCode'].toString(),
        );

        if (docente == null) {
          continue;
        }

        asesorias.add(Asesoria.fromJson(asesoriaJson, docente: docente));
      }

      return asesorias;
    } catch (e) {
      debugPrint('Error cargando asesorias: $e');
      return [];
    }
  }
}
