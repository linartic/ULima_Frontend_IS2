import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';

class DaySchedule {
  final String dayName;
  final String dateText;
  final String weekText;

  DaySchedule(this.dayName, this.dateText, this.weekText);
}

class HorarioController extends GetxController {
  final currentDayIndex = 0.obs;
  final daysList = <DaySchedule>[].obs;
  
  // Lista donde almacenaremos todas las secciones cargadas del JSON
  List<Map<String, dynamic>> _todasLasSecciones = [];

  @override
  void onInit() {
    super.onInit();
    _loadDays();
    _loadSecciones();
  }

  // Carga los días de la semana
  Future<void> _loadDays() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/schedule_days.json');
      final List<dynamic> decoded = jsonDecode(jsonString);
      daysList.assignAll(decoded.map((d) => DaySchedule(
        d['dayName'] as String,
        d['dateText'] as String,
        d['weekText'] as String,
      )).toList());
      
      // Auto-selecciona el viernes si existe, sino el primero
      final idx = daysList.indexWhere((d) => d.dayName == 'Viernes');
      currentDayIndex.value = idx != -1 ? idx : 0;
    } catch (e) {
      print('Error al cargar días: $e');
    }
  }

  // Carga el archivo secciones.json que contiene el horario detallado
  Future<void> _loadSecciones() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/secciones.json');
      final Map<String, dynamic> data = jsonDecode(jsonString);
      _todasLasSecciones = List<Map<String, dynamic>>.from(data['secciones']);
      update(); // Notifica a la UI que los datos están listos
    } catch (e) {
      print('Error al cargar secciones: $e');
    }
  }

  DaySchedule? get currentDay => daysList.isEmpty ? null : daysList[currentDayIndex.value];

  // Filtra las secciones para el día seleccionado y según el usuario actual
  List<Map<String, dynamic>> get currentDayCourses {
    final activeDay = currentDay;
    if (activeDay == null || _todasLasSecciones.isEmpty) return const [];

    // 1. Obtener los IDs de las secciones donde el usuario está inscrito
    final user = AuthService.to.currentUser;
    final List<dynamic> inscritas = user?.courseProgress?.currentCourses ?? [];
    
    // Extraemos solo los IDs de sección para comparar rápidamente
    final List<String> idsInscritos = inscritas
        .map((i) => (i['idSeccion'] as String? ?? ''))
        .where((id) => id.isNotEmpty)
        .toList();

    // 2. Filtrar secciones: deben coincidir con el día y estar en los inscritos del usuario
    final currentDayName = activeDay.dayName.toLowerCase();

    return _todasLasSecciones.where((s) {
      final courseDay = (s['dia'] as String? ?? '').toLowerCase();
      final esMismoDia = courseDay == currentDayName;
      final estaInscrito = idsInscritos.contains(s['idSeccion']);
      
      return esMismoDia && estaInscrito;
    }).toList();
  }

  void previousDay() {
    if (daysList.isEmpty) return;
    currentDayIndex.value = (currentDayIndex.value > 0) 
        ? currentDayIndex.value - 1 
        : daysList.length - 1;
  }

  void nextDay() {
    if (daysList.isEmpty) return;
    currentDayIndex.value = (currentDayIndex.value < daysList.length - 1) 
        ? currentDayIndex.value + 1 
        : 0;
  }
}