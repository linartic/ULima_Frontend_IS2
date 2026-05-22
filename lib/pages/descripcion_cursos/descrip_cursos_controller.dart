import 'package:get/get.dart';
import 'package:ulima_plus/models/anuncio_model.dart';
import 'package:ulima_plus/models/docente_model.dart';
import 'package:ulima_plus/models/seccion_model.dart';
import 'package:ulima_plus/models/user_model.dart';
import 'package:ulima_plus/services/anuncio_service.dart';
import 'package:ulima_plus/services/contacto_service.dart';
import '../../models/asesoria_model.dart';
import '../../services/asesoria_service.dart';
import '../../services/seccion_service.dart';

class DescripCursosController extends GetxController {
  // 1. Declaraciones únicas (sin duplicados)
  RxList<Seccion> secciones = <Seccion>[].obs;
  RxList<Anuncio> anuncios = <Anuncio>[].obs;
  RxList<Asesoria> asesorias = <Asesoria>[].obs;
  RxList<UserModel> alumnosContacto = <UserModel>[].obs;
  Rxn<Docente> docenteContacto = Rxn<Docente>();
  RxInt selectedTab = 0.obs;

  // Método para buscar sección por ID (útil para tu UI)
  Seccion? getSeccionPorId(String id) {
    return secciones.firstWhereOrNull((s) => s.idSeccion == id);
  }

  // Ahora recibe el idSeccion para cargar los datos específicos
  void cargarDatosCurso(String idSeccion) {
    fetchSecciones();
    fetchAnuncios(idSeccion);
    fetchAsesorias(idSeccion);
    fetchContactos(idSeccion);
  }

  Future<void> fetchSecciones() async {
    final service = SeccionService();
    final data = await service.fetchSecciones();
    secciones.value = data;
  }

  Future<void> fetchAnuncios(String idSeccion) async {
    final service = AnuncioService();
    // Asegúrate de que tu servicio acepte el ID
    final data = await service.fetchAnuncios(idSeccion);
    anuncios.value = data;
  }

  Future<void> fetchAsesorias(String idSeccion) async {
    final service = AsesoriaService();
    final data = await service.fetchAsesorias(idSeccion);
    asesorias.value = data;
  }

  Future<void> fetchContactos(String idSeccion) async {
    final service = ContactoService();
    final data = await service.fetchContactos(idSeccion);
    docenteContacto.value = data['docente'];
    alumnosContacto.value = data['alumnos'];
  }
}
