import 'dart:convert';
import 'package:flutter/foundation.dart';
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

  List<Map<String, dynamic>> _todasLasSecciones = [];

  @override
  void onInit() {
    super.onInit();
    _loadDays();
    _loadSecciones();
  }

  Future<void> _loadDays() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/schedule_days.json',
      );
      final List<dynamic> decoded = jsonDecode(jsonString);
      daysList.assignAll(
        decoded
            .map(
              (d) => DaySchedule(
                d['dayName'] as String,
                d['dateText'] as String,
                d['weekText'] as String,
              ),
            )
            .toList(),
      );
      final idx = daysList.indexWhere((d) => d.dayName == 'Viernes');
      currentDayIndex.value = idx != -1 ? idx : 0;
    } catch (e) {
      debugPrint('Error al cargar dias: $e');
    }
  }

  Future<void> _loadSecciones() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/secciones.json',
      );
      final Map<String, dynamic> data = jsonDecode(jsonString);
      _todasLasSecciones = List<Map<String, dynamic>>.from(data['secciones']);
      update();
    } catch (e) {
      debugPrint('Error al cargar secciones: $e');
    }
  }

  DaySchedule? get currentDay =>
      daysList.isEmpty ? null : daysList[currentDayIndex.value];

  List<Map<String, dynamic>> get currentDayCourses {
    final activeDay = currentDay;
    if (activeDay == null || _todasLasSecciones.isEmpty) return const [];

    final user = AuthService.to.currentUser;
    final List<dynamic> inscritas = user?.courseProgress?.currentCourses ?? [];

    final idsInscritos = inscritas
        .map((i) => (i['idSeccion'] as String? ?? ''))
        .where((id) => id.isNotEmpty)
        .toList();

    final currentDayName = activeDay.dayName.toLowerCase();

    final courses = <Map<String, dynamic>>[];

    for (final section in _todasLasSecciones) {
      final estaInscrito = idsInscritos.contains(section['idSeccion']);
      if (!estaInscrito) continue;

      final horarios = section['horarios'];
      if (horarios is List && horarios.isNotEmpty) {
        for (final rawHorario in horarios) {
          if (rawHorario is! Map) continue;
          final horario = Map<String, dynamic>.from(rawHorario);
          final courseDay = (horario['dia'] as String? ?? '').toLowerCase();
          if (courseDay != currentDayName) continue;

          courses.add({...section, ...horario});
        }
        continue;
      }

      final courseDay = (section['dia'] as String? ?? '').toLowerCase();
      if (courseDay == currentDayName) {
        courses.add(section);
      }
    }

    return courses;
  }

  void previousDay() {
    if (daysList.isEmpty) return;
    if (currentDayIndex.value > 0) {
      currentDayIndex.value--;
    } else {
      currentDayIndex.value = daysList.length - 1;
    }
  }

  void nextDay() {
    if (daysList.isEmpty) return;
    if (currentDayIndex.value < daysList.length - 1) {
      currentDayIndex.value++;
    } else {
      currentDayIndex.value = 0;
    }
  }
}
