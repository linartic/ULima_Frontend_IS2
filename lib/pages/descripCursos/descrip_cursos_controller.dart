import 'package:get/get.dart';

import '../../models/seccion_model.dart';
import '../../services/seccion_service.dart';

class DescripCursosController extends GetxController {
  RxList<Seccion> secciones = <Seccion>[].obs;

  RxInt selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSecciones();
  }

  Future<void> fetchSecciones() async {
    final service = SeccionService();

    await service.loadSeccionesData();

    final data = service.allSecciones;

    secciones.value = data.map((s) => Seccion.fromJson(s)).toList();
  }
}
