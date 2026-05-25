import 'package:flutter/foundation.dart';
import 'package:ulima_plus/models/contacto_model.dart';

import 'docente_service.dart';
import 'enrollment_service.dart';
import 'seccion_service.dart';
import 'section_representative_service.dart';
import 'user_service.dart';

class ContactoService {
  final UserService _userService = UserService();
  final DocenteService _docenteService = DocenteService();
  final SeccionService _seccionService = SeccionService();
  final EnrollmentService _enrollmentService = EnrollmentService();
  final SectionRepresentativeService _representativeService =
      SectionRepresentativeService();

  Future<Map<String, dynamic>> fetchContactos(String idSeccion) async {
    try {
      final seccion = await _seccionService.findSectionById(idSeccion);
      if (seccion == null) {
        throw Exception('No existe seccion $idSeccion');
      }

      final docente = await _docenteService.findDocenteByCode(
        seccion.docenteCode,
      );
      final enrollments = await _enrollmentService.fetchBySection(idSeccion);
      final List<ContactoCurso> contactos = [];

      for (final enrollment in enrollments) {
        final user = await _userService.findUserByCode(enrollment.studentCode);

        if (user != null) {
          final role = await _representativeService.getRoleInSection(
            idSeccion,
            user.code,
          );

          contactos.add(ContactoCurso(user: user, roleInSection: role));
        }
      }

      contactos.sort((a, b) {
        final compare = _rolePriority(
          a.roleInSection,
        ).compareTo(_rolePriority(b.roleInSection));

        if (compare == 0) {
          return a.user.lastName.compareTo(b.user.lastName);
        }

        return compare;
      });

      return {'docente': docente, 'alumnos': contactos};
    } catch (e) {
      debugPrint('Error cargando contactos: $e');

      return {'docente': null, 'alumnos': <ContactoCurso>[]};
    }
  }

  int _rolePriority(String role) {
    switch (role) {
      case 'delegado':
        return 0;
      case 'subdelegado':
        return 1;
      default:
        return 2;
    }
  }
}
