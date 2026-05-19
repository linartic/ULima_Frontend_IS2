// lib/pages/setup_carrera/setup_carrera_controller.dart
// CU3 + CU4 – configuración de carrera y especialidades.

import 'package:get/get.dart';

import '../../services/auth_service.dart';

class SetupCarreraController extends GetxController {
  static const carreraFija = 'Ingeniería de Sistemas';

  final especialidadesDisponibles = const <String>[
    'Desarrollo de Software',
    'Ciberseguridad',
    'Ciencia de Datos',
    'Tecnologías de la Información',
  ];

  final selectedCarrera = carreraFija.obs;
  final selectedEspecialidades = <String>{}.obs;
  final errorMessage = RxnString();
  final saving = false.obs;

  AuthService get _auth => AuthService.to;

  @override
  void onInit() {
    super.onInit();
    final u = _auth.currentUser;
    if (u?.especialidades.isNotEmpty == true) {
      selectedEspecialidades.assignAll(u!.especialidades);
    }
  }

  void toggleEspecialidad(String esp) {
    if (selectedEspecialidades.contains(esp)) {
      selectedEspecialidades.remove(esp);
    } else {
      selectedEspecialidades.add(esp);
    }
  }

  Future<void> finish() async {
    errorMessage.value = null;
    saving.value = true;
    // Aquí podríamos persistir contra un backend en el futuro.
    // Por ahora actualizamos el usuario en memoria.
    _auth.completeSetup(
      career: selectedCarrera.value,
      especialidades: selectedEspecialidades.toList(),
    );
    saving.value = false;
    Get.offAllNamed('/home');
  }
}
