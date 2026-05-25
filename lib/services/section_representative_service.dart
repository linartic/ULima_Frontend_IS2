import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/section_representative_model.dart';
import 'enrollment_service.dart';

class SectionRepresentativeService {
  final EnrollmentService _enrollmentService = EnrollmentService();

  Future<List<SectionRepresentative>> fetchRepresentatives() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/section_representative.json',
      );
      final data = json.decode(response);
      final List<dynamic> raw = data['sectionRepresentatives'] ?? [];
      return raw.map((r) => SectionRepresentative.fromJson(r)).toList();
    } catch (e) {
      debugPrint('Error cargando representantes: $e');
      return [];
    }
  }

  Future<String> getRoleInSection(String idSeccion, String studentCode) async {
    final representatives = await fetchRepresentatives();

    for (final rep in representatives) {
      final enrollment = await _enrollmentService.findById(rep.enrollmentId);

      if (enrollment != null &&
          enrollment.idSeccion == idSeccion &&
          enrollment.studentCode == studentCode) {
        return rep.role;
      }
    }

    return 'estudiante';
  }

  Future<bool> isRepresentativeInAnySection(String studentCode) async {
    final representatives = await fetchRepresentatives();

    for (final rep in representatives) {
      final enrollment = await _enrollmentService.findById(rep.enrollmentId);

      if (enrollment != null &&
          enrollment.studentCode == studentCode &&
          (rep.role == 'delegado' || rep.role == 'subdelegado')) {
        return true;
      }
    }

    return false;
  }
}
