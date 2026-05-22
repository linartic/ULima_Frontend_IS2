import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../descripcion_cursos/descrip_cursos.dart';
import 'horario_controller.dart';


class HorarioPage extends StatelessWidget {
  const HorarioPage({super.key});

  static const double startHour = 7.0;
  static const double endHour = 22.0;
  static const double hourHeight = 85.0;

  double _timeToHours(String timeStr) {
    try {
      final cleanStr = timeStr.trim().toLowerCase();
      final parts = cleanStr.split(' ');
      if (parts.length < 2) return 7.0;
      
      final isPm = parts[1] == 'pm';
      final hms = parts[0].split(':');
      int hour = int.tryParse(hms[0]) ?? 12;
      int minute = hms.length > 1 ? (int.tryParse(hms[1]) ?? 0) : 0;
      
      if (isPm && hour != 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;
      
      return hour + (minute / 60.0);
    } catch (_) {
      return 7.0;
    }
  }



  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HorarioController());
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E26) : const Color(0xFFF8F9FA),
      body: Obx(() {
        final activeDay = controller.currentDay;
        if (activeDay == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final courses = controller.currentDayCourses;
        final totalHours = (endHour - startHour).toInt() + 1;

        return Column(
          children: [
            Container(
              color: isDark ? const Color(0xFF262630) : const Color(0xFFFFF2EC),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: colors.primary,
                      size: 20,
                    ),
                    onPressed: controller.previousDay,
                  ),
                  Text(
                    '${activeDay.dayName}, ${activeDay.dateText}',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: colors.primary,
                      size: 20,
                    ),
                    onPressed: controller.nextDay,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE5E5E5)),
            Container(
              width: double.infinity,
              color: isDark ? const Color(0xFF1B1B22) : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              child: Text(
                activeDay.weekText,
                style: TextStyle(
                  color: isDark ? const Color(0xFFB0B0C0) : const Color(0xFF666666),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE5E5E5)),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Stack(
                    children: [
                      Column(
                        children: List.generate(totalHours, (index) {
                          final hourVal = startHour + index;
                          final isPm = hourVal >= 12;
                          final displayHour = hourVal > 12 
                              ? (hourVal - 12).toInt() 
                              : hourVal.toInt();
                          final amPm = isPm ? 'pm' : 'am';
                          
                          return SizedBox(
                            height: hourHeight,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 65,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16, top: 4),
                                    child: Text(
                                      '$displayHour $amPm',
                                      style: TextStyle(
                                        color: isDark ? const Color(0xFF9090A0) : const Color(0xFF9E9E9E),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 12),
                                    height: 1.2,
                                    color: isDark ? const Color(0xFF2C2C38) : const Color(0xFFECECEC),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                      ...courses.map((course) {
                        final nombreStr = (course['name'] as String? ?? course['nombre'] as String? ?? '').toUpperCase();
                        final aulaStr = course['code'] as String? ?? '';
                        final colorStr = course['color'] as String? ?? 'blue';
                        final startStr = course['hora_inicio'] as String? ?? '07:00 am';
                        final endStr = course['hora_fin'] as String? ?? '09:00 am';

                        final startVal = _timeToHours(startStr);
                        final endVal = _timeToHours(endStr);

                        final double topPosition = (startVal - startHour) * hourHeight + 12.0;
                        final double heightVal = (endVal - startVal) * hourHeight - 8.0;

                        final courseColor = {
                          'pink': colors.secondaryContainer,
                          'blue': colors.secondary,
                          'orange': colors.primary,
                          'green': colors.tertiaryContainer,
                          'purple': colors.tertiary,
                          'teal': colors.primaryContainer,
                          'red': colors.error,
                        }[colorStr.toLowerCase()] ?? colors.outline;

                        return Positioned(
                          top: topPosition,
                          left: 75,
                          right: 20,
                          height: heightVal,
                          child: InkWell(
                            onTap: () {
                              Get.to(() => DescripCursosPage());
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: courseColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: courseColor.withOpacity(0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    nombreStr,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    aulaStr,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
