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
    return _auth.especialidades
        .where((e) => e['carrera_id'] == cId && e['is_active'] == true)
        .toList();
  }

  String get selectedCarreraName {
    return _auth.getCareerName(selectedCarreraId.value);
  }

  @override
  void onInit() {
    super.onInit();
    final u = _auth.currentUser;
    if (u != null) {
      selectedCarreraId.value = u.careerId ?? 1;
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
    saving.value = true;

    final cId = selectedCarreraId.value;
    if (cId == null) {
      errorMessage.value = 'Por favor, selecciona una carrera.';
      saving.value = false;
      return;
    }

    _auth.completeSetup(
      careerId: cId,
      especialidades: selectedEspecialidades.toList(),
    );
    saving.value = false;
    Get.offAllNamed('/home');
  }
}
