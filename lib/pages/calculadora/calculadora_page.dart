import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/calculadora/curso_card.dart';
import '../../components/calculadora/add_nota_with_syllabus_modal.dart';
import 'calculadora_controller.dart';
import '../../components/header/app_header.dart';
import '../../components/footer/app_footer.dart';

// Usamos GetView para evitar el Get.put manual si ya está en los bindings,
// o simplemente para tener acceso directo a 'controller'.
class CalculadoraPage extends GetView<CalculadoraController> {
  const CalculadoraPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Extraemos el esquema de colores (cambiará solo si el sistema está en Dark Mode)
    final colors = Theme.of(context).colorScheme;
    
    Get.lazyPut(() => CalculadoraController());

    return Scaffold(
      // En tu darkScheme pusiste surface: Color(0xFF1F1F1F)
      backgroundColor: colors.surface, 
      body: Column(
        children: [
          const AppHeader(),
          
          // Header de Calculadora de Notas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration( // Quitamos 'const' para usar variables
              color: colors.surface, 
              border: Border(
                top: BorderSide(color: colors.primaryContainer, width: 2.0),
                // Usará primaryColor (0xFFFF6600) tanto en light como dark según tu código
                //bottom: BorderSide(color: colors.primaryContainer, width: 2.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Calculadora de Notas",
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface, // Blanco en Dark, Negro en Light
                  ),
                ),
                Obx(() {
                  final cursosConNotas = controller.cursos
                      .where((curso) => (curso['notas'] as List?)?.isNotEmpty ?? false)
                      .length;
                  return Text(
                    "Cursos con notas: $cursosConNotas",
                    style: TextStyle(
                      // onSurfaceVariant suele ser un gris que se adapta
                      color: colors.onSurface.withOpacity(0.7), 
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                }),
              ],
            ),
          ),

          // Lista de cursos (solo los que tienen notas registradas)
          Expanded(
            child: Obx(() {
              final cursosConNotas = controller.cursos
                  .where((curso) => (curso['notas'] as List?)?.isNotEmpty ?? false)
                  .toList();

              if (cursosConNotas.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_ind,
                        size: 64,
                        color: colors.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay notas registradas',
                        style: TextStyle(
                          fontSize: 16,
                          color: colors.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Comienza registrando una nota',
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: cursosConNotas.length,
                itemBuilder: (context, index) {
                  final curso = cursosConNotas[index];
                  final notas = curso['notas'] as List;
                  
                  return CursoCard(
                    curso: curso,
                    cursoIndex: controller.cursos.indexOf(curso),
                    promedio: controller.calcularPromedio(notas),
                    sumaPesos: controller.sumaPesos(notas),
                    onDeleteNota: controller.eliminarNota,
                  );
                },
              );
            }),
          ),

          // Botón Agregar Nota - Versión mejorada
          Padding(
            padding: const EdgeInsets.all(20),
            child: Obx(() {
              final tieneNotas = controller.cursos.isNotEmpty;
              return ElevatedButton.icon(
                onPressed: tieneNotas
                    ? () {
                        // Mostrar diálogo para seleccionar curso si hay múltiples
                        if (controller.cursos.length == 1) {
                          _mostrarModalAgregarNota(context, 0, controller);
                        } else {
                          _mostrarDialogoSeleccionarCurso(
                            context,
                            controller,
                          );
                        }
                      }
                    : null,
                icon: const Icon(Icons.add),
                label: const Text("Registrar Nota"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primaryContainer,
                  foregroundColor: colors.onPrimary,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  disabledBackgroundColor:
                      colors.primaryContainer.withOpacity(0.5),
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: AppFooter(
        currentIndex: 1,
        onTap: (index) => print("Navegando al índice: $index"),
      ),
    );
  }

  /// Muestra el modal para agregar nota para un curso específico
  void _mostrarModalAgregarNota(
    BuildContext context,
    int cursoIndex,
    CalculadoraController controller,
  ) {
    final colors = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => AddNotaWithSyllabusModal(
        cursoIndex: cursoIndex,
        cursoData: controller.cursos[cursoIndex],
      ),
    );
  }

  /// Muestra un diálogo para seleccionar el curso antes de agregar nota
  void _mostrarDialogoSeleccionarCurso(
    BuildContext context,
    CalculadoraController controller,
  ) {
    final colors = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecciona un Curso',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              controller.cursos.length,
              (index) {
                // Extraemos los datos de forma segura aquí
                final curso = controller.cursos[index];
                final seccion = curso['seccion']?.toString() ?? 'Sin sección';
                final nombre = curso['nombre']?.toString() ?? 'Curso desconocido';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        _mostrarModalAgregarNota(context, index, controller);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Usamos las variables seguras directamente
                            Text(
                              "Sección: $seccion", 
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                              ),
                            ),
                            Text(
                              nombre,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }}