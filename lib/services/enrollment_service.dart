import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/enrollment_model.dart';

class EnrollmentService {
  Future<List<Enrollment>> fetchEnrollments() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/enrollments.json',
      );
      final data = json.decode(response);
      final List<dynamic> raw = data['enrollments'] ?? [];
      return raw.map((e) => Enrollment.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error cargando enrollments: $e');
      return [];
    }
  }

  Future<List<Enrollment>> fetchBySection(String idSeccion) async {
    final enrollments = await fetchEnrollments();
    return enrollments.where((e) => e.idSeccion == idSeccion).toList();
  }

  Future<Enrollment?> findById(String id) async {
    final enrollments = await fetchEnrollments();
    try {
      return enrollments.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }
}
