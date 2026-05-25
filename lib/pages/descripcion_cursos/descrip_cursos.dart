import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../configs/themes.dart';
import '../../models/seccion_model.dart';
import 'anuncios_tab.dart';
import 'asesoria_tab.dart';
import 'contactos_tab.dart';
import 'descrip_cursos_controller.dart';

class DescripCursosPage extends StatelessWidget {
  final String idSeccion;
  final DescripCursosController control = Get.put(DescripCursosController());

  DescripCursosPage({super.key, required this.idSeccion}) {
    control.cargarDatosCurso(idSeccion);
  }

  Color _sectionBackground(ColorScheme colors) =>
      MaterialTheme.bloqueSeccion(colors.brightness);
  Color _attendanceBackground(ColorScheme colors) =>
      MaterialTheme.bloqueAsistencia(colors.brightness);
  Color _attendanceDivider(ColorScheme colors) =>
      MaterialTheme.bloqueAsistenciaLinea(colors.brightness);

  Widget _courseTitle(BuildContext context, Seccion seccion) {
    ColorScheme colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.primary,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.paddingOf(context).top + 30,
          20,
          18,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Text(
                seccion.curso,
                style: TextStyle(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),

            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () {
                  Get.back();
                },
                child: Icon(Icons.arrow_back, color: colors.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, Seccion seccion) {
    ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,

      color: _sectionBackground(colors),

      padding: const EdgeInsets.symmetric(vertical: 10),

      child: Center(
        child: Text(
          'Sección: ${seccion.codigoSeccion}',
          style: TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _asistencia(BuildContext context, Seccion seccion) {
    ColorScheme colors = Theme.of(context).colorScheme;

    int asistido = seccion.asistido;

    int inasistencia = seccion.inasistencia;

    int total = seccion.total;

    double porcentaje = asistido / total;

    return Container(
      width: double.infinity,

      color: _attendanceBackground(colors),

      padding: const EdgeInsets.all(20),

      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Asistencia',

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        const Text(
                          '✓',

                          style: TextStyle(color: Colors.green, fontSize: 22),
                        ),

                        const SizedBox(width: 16),

                        Text('$asistido horas'),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Text(
                          '✗',

                          style: TextStyle(color: Colors.red, fontSize: 22),
                        ),

                        const SizedBox(width: 16),

                        Text('$inasistencia horas'),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Container(height: 1, color: _attendanceDivider(colors)),

                    const SizedBox(height: 14),

                    Padding(
                      padding: const EdgeInsets.only(left: 38),

                      child: Text(
                        '$total horas',

                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: 120,
                height: 120,

                child: Stack(
                  alignment: Alignment.center,

                  children: [
                    SizedBox(
                      width: 90,
                      height: 90,

                      child: CircularProgressIndicator(
                        value: porcentaje,

                        strokeWidth: 16,

                        backgroundColor: Colors.red,

                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.green,
                        ),
                      ),
                    ),

                    Container(
                      width: 48,
                      height: 48,

                      decoration: BoxDecoration(
                        color: _attendanceBackground(colors),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required int index,
  }) {
    ColorScheme colors = Theme.of(context).colorScheme;
    return Obx(() {
      bool isSelected = control.selectedTab.value == index;
      return Expanded(
        child: InkWell(
          onTap: () => control.selectedTab.value = index,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected ? colors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? colors.primary : Colors.grey,
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? colors.primary : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _tabs(BuildContext context) {
    ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      color: colors.surface,
      child: Row(
        children: [
          _tabItem(
            context: context,
            icon: Icons.notifications_none,
            text: 'Anuncios',
            index: 0,
          ),
          _tabItem(
            context: context,
            icon: Icons.bookmark_border,
            text: 'Asesorías',
            index: 1,
          ),
          _tabItem(
            context: context,
            icon: Icons.people_outline,
            text: 'Contactos',
            index: 2,
          ),
        ],
      ),
    );
  }

  Widget _selectedPage(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Obx(() {
          switch (control.selectedTab.value) {
            case 0:
              return AnunciosTab(idSeccion: idSeccion);
            case 1:
              return AsesoriasTab(idSeccion: idSeccion);
            case 2:
              return ContactosTab(idSeccion: idSeccion);
            default:
              return AnunciosTab(idSeccion: idSeccion);
          }
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final seccion = control.getSeccionPorId(idSeccion);

      if (seccion == null) {
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Column(
          children: [
            _courseTitle(context, seccion),
            _section(context, seccion),
            _asistencia(context, seccion),
            _tabs(context),
            Expanded(child: _selectedPage(context)),
          ],
        ),
      );
    });
  }
}
