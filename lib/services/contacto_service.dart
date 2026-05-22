import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/user_model.dart';

import 'user_service.dart';
import 'docente_service.dart';

class ContactoService {
  final UserService _userService = UserService();

  final DocenteService _docenteService = DocenteService();

  // Obtiene contactos
  Future<Map<String, dynamic>> fetchContactos(String idSeccion) async {
    // Carga JSON
    final String response = await rootBundle.loadString(
      'assets/data/contactos.json',
    );

    // Convierte JSON
    final data = json.decode(response);

    // Lista contactos
    final List contactos = data['contactos'];

    // Busca sección
    final contacto = contactos.firstWhere((c) => c['idSeccion'] == idSeccion);

    // Busca docente
    final docente = await _docenteService.findDocenteByCode(
      contacto['docenteCode'],
    );

    // Lista códigos alumnos
    final List alumnosCodes = contacto['alumnos'];

    // Lista final alumnos
    List<UserModel> alumnos = [];

    // Busca alumnos
    for (String code in alumnosCodes) {
      final user = await _userService.findUserByCode(code);

      if (user != null) {
        alumnos.add(user);
      }
    }

    alumnos.sort((a, b) {
      // Delegado primero
      if (a.role == 'delegado' && b.role != 'delegado') {
        return -1;
      }

      // Subdelegado segundo
      if (a.role == 'subdelegado' && b.role == 'estudiante') {
        return -1;
      }

      // Orden alfabético
      return a.lastName.compareTo(b.lastName);
    });

    // Resultado final
    return {'docente': docente, 'alumnos': alumnos};
  }
}
