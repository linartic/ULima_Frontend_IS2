import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SeccionService {
  static final SeccionService _instance = SeccionService._internal();

  factory SeccionService() {
    return _instance;
  }

  SeccionService._internal();

  late List<Map<String, dynamic>> _seccionesData;

  bool _isLoaded = false;

  Future<void> loadSeccionesData() async {
    if (_isLoaded) return;

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/seccion.json',
      );

      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      final seccionesList = jsonData['seccion'] as List<dynamic>? ?? [];

      _seccionesData = List<Map<String, dynamic>>.from(seccionesList);

      _isLoaded = true;

      debugPrint('Secciones cargadas');
    } catch (e) {
      debugPrint('Error cargando secciones: $e');

      rethrow;
    }
  }

  List<Map<String, dynamic>> get allSecciones => _seccionesData;

  bool get isLoaded => _isLoaded;
}
