import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../services/courses_service.dart';

class DaySchedule {
  final String dayName;
  final String dateText;
  final String weekText;

  DaySchedule(this.dayName, this.dateText, this.weekText);
}

class HorarioController extends GetxController {
  final currentDayIndex = 0.obs;
  final daysList = <DaySchedule>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDays();
  }

  Future<void> _loadDays() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/schedule_days.json');
      final List<dynamic> decoded = jsonDecode(jsonString);
      daysList.assignAll(decoded.map((d) => DaySchedule(
        d['dayName'] as String,
        d['dateText'] as String,
        d['weekText'] as String,
      )).toList());
      final idx = daysList.indexWhere((d) => d.dayName == 'Viernes');
      currentDayIndex.value = idx != -1 ? idx : 0;
    } catch (_) {}
  }

  DaySchedule? get currentDay => daysList.isEmpty ? null : daysList[currentDayIndex.value];

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

  List<Map<String, dynamic>> get currentDayCourses {
    final activeDay = currentDay;
    if (activeDay == null) return const [];

    final courses = CoursesService().allCourses;
    final active = courses.where((c) => c['is_active'] == true).toList();
    final currentDayName = activeDay.dayName.toLowerCase();

    return active.where((c) {
      final courseDay = (c['dia'] as String? ?? '').toLowerCase();
      return courseDay == currentDayName;
    }).toList();
  }
}
