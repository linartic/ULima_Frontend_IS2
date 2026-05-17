// lib/pages/setup_carrera/setup_carrera_controller.dart
// CU3 + CU4 – configuración de carrera y especialidades.

import 'package:get/get.dart';

import '../../services/auth_service.dart';

class SetupCarreraController extends GetxController {
  final carreras = const <String>[
    'Ingeniería de Sistemas',
  ];

  final especialidadesDisponibles = const <String>[
    'Desarrollo de Software',
    'Ciberseguridad',
    'Ciencia de Datos',
    'Tecnologías de la Información',
  ];

  final selectedCarrera = RxnString();
  final selectedEspecialidades = <String>{}.obs;
  final errorMessage = RxnString();
  final saving = false.obs;

  AuthService get _auth => AuthService.to;

  @override
  void onInit() {
    super.onInit();
    // Si el usuario ya tenía carrera previa (por si vuelve a setup), la pre-cargamos
    final u = _auth.currentUser;
    if (u?.career != null && carreras.contains(u!.career)) {
      selectedCarrera.value = u.career;
    }
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
    if (selectedCarrera.value == null) {
      errorMessage.value = 'Selecciona tu carrera para continuar.';
      return;
    }
    errorMessage.value = null;
    saving.value = true;
    // Aquí podríamos persistir contra un backend en el futuro.
    // Por ahora actualizamos el usuario en memoria.
    _auth.completeSetup(
      career: selectedCarrera.value!,
      especialidades: selectedEspecialidades.toList(),
    );
    saving.value = false;
    Get.offAllNamed('/home');
  }
}
