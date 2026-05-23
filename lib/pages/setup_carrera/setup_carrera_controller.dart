import 'package:get/get.dart';

import '../../services/auth_service.dart';

class SetupCarreraController extends GetxController {
  final selectedCarreraId = RxnInt();
  final selectedEspecialidades = <int>{}.obs;
  final errorMessage = RxnString();
  final saving = false.obs;

  AuthService get _auth => AuthService.to;

  List<Map<String, dynamic>> get carreras => _auth.carreras;

  List<Map<String, dynamic>> get especialidadesDisponibles {
    final cId = selectedCarreraId.value;
    if (cId == null) return const [];
    final list = _auth.especialidades
        .where((e) => e['carrera_id'] == cId && e['is_active'] == true)
        .toList();
    list.sort((a, b) {
      final orderA = (a['display_order'] as num?)?.toInt() ?? 999;
      final orderB = (b['display_order'] as num?)?.toInt() ?? 999;
      return orderA.compareTo(orderB);
    });
    return list;
  }

  String get selectedCarreraName {
    return _auth.getCareerName(selectedCarreraId.value);
  }

  @override
  void onInit() {
    super.onInit();
    final u = _auth.currentUser;
    final defaultCarrera = carreras.firstWhereOrNull(
      (c) => c['is_active'] == true,
    );
    selectedCarreraId.value =
        u?.careerId ?? (defaultCarrera?['id'] as int?) ?? 1;

    if (u != null && u.especialidades.isNotEmpty) {
      selectedEspecialidades.assignAll(u.especialidades);
    }
  }

  void toggleEspecialidad(int id) {
    if (selectedEspecialidades.contains(id)) {
      selectedEspecialidades.remove(id);
    } else {
      selectedEspecialidades.add(id);
    }
  }

  Future<void> finish() async {
    errorMessage.value = null;

    final cId = selectedCarreraId.value;
    if (cId == null) {
      errorMessage.value = 'Por favor, selecciona una carrera.';
      return;
    }

    saving.value = true;
    try {
      await _auth.completeSetup(
        careerId: cId,
        especialidades: selectedEspecialidades.toList(),
      );
      Get.offAllNamed('/home');
    } catch (e) {
      errorMessage.value = 'No pudimos guardar la configuración: $e';
    } finally {
      saving.value = false;
    }
  }
}
