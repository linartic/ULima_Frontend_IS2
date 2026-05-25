import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ulima_plus/models/anuncio_model.dart';
import 'package:ulima_plus/models/asesoria_model.dart';
import 'package:ulima_plus/models/contacto_model.dart';
import 'package:ulima_plus/models/docente_model.dart';
import 'package:ulima_plus/models/seccion_model.dart';
import 'package:ulima_plus/services/anuncio_service.dart';
import 'package:ulima_plus/services/asesoria_service.dart';
import 'package:ulima_plus/services/contacto_service.dart';
import 'package:ulima_plus/services/seccion_service.dart';

class DescripCursosController extends GetxController {
  final SeccionService _seccionService = SeccionService();
  final AnuncioService _anuncioService = AnuncioService();
  final AsesoriaService _asesoriaService = AsesoriaService();
  final ContactoService _contactoService = ContactoService();

  RxList<Seccion> secciones = <Seccion>[].obs;
  Rxn<Seccion> seccionActual = Rxn<Seccion>();
  RxList<Anuncio> anuncios = <Anuncio>[].obs;
  RxList<Asesoria> asesorias = <Asesoria>[].obs;
  RxList<ContactoCurso> alumnosContacto = <ContactoCurso>[].obs;
  Rxn<Docente> docenteContacto = Rxn<Docente>();
  RxInt selectedTab = 0.obs;
  RxBool isLoading = false.obs;

  Seccion? getSeccionPorId(String id) {
    return secciones.firstWhereOrNull((s) => s.idSeccion == id);
  }

  Future<void> cargarDatosCurso(String idSeccion) async {
    try {
      isLoading.value = true;
      final seccion = await _seccionService.findSectionById(idSeccion);
      if (seccion == null) {
        throw Exception('No existe seccion con id $idSeccion');
      }

      seccionActual.value = seccion;
      secciones.value = [seccion];

      await Future.wait([
        fetchAnuncios(idSeccion),
        fetchAsesorias(idSeccion),
        fetchContactos(idSeccion),
      ]);
    } catch (e) {
      debugPrint('Error cargando datos del curso: $e');
      limpiarDatos();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAnuncios(String idSeccion) async {
    final data = await _anuncioService.fetchAnuncios(idSeccion);
    anuncios.value = data;
  }

  Future<void> fetchAsesorias(String idSeccion) async {
    final data = await _asesoriaService.fetchAsesorias(idSeccion);
    asesorias.value = data;
  }

  Future<void> fetchContactos(String idSeccion) async {
    final data = await _contactoService.fetchContactos(idSeccion);
    docenteContacto.value = data['docente'] as Docente?;
    alumnosContacto.value = List<ContactoCurso>.from(data['alumnos'] ?? []);
  }

  void limpiarDatos() {
    secciones.clear();
    seccionActual.value = null;
    anuncios.clear();
    asesorias.clear();
    alumnosContacto.clear();
    docenteContacto.value = null;
  }
}
