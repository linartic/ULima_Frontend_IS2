import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/calculadora/curso_card.dart';
import '../../components/calculadora/add_nota_modal.dart';
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
                // Usará primaryColor (0xFFFF6600) tanto en light como dark según tu código
                bottom: BorderSide(color: colors.primary, width: 2.0),
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
                Obx(() => Text(
                  "Cursos cursando actualmente: ${controller.cursos.length}",
                  style: TextStyle(
                    // onSurfaceVariant suele ser un gris que se adapta
                    color: colors.onSurface.withOpacity(0.7), 
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                )),
              ],
            ),
          ),

          // Lista de cursos
          Expanded(
            child: Obx(() => ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: controller.cursos.length,
              itemBuilder: (context, index) {
                final curso = controller.cursos[index];
                final notas = curso['notas'] as List;
                
                return CursoCard(
                  curso: curso,
                  cursoIndex: index,
                  promedio: controller.calcularPromedio(notas),
                  sumaPesos: controller.sumaPesos(notas),
                  onDeleteNota: controller.eliminarNota,
                );
              },
            )),
          ),

          // Botón Agregar Nota
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: colors.surface, // Para que el modal también sea oscuro
                builder: (_) => const AddNotaModal(),
              ),
              icon: const Icon(Icons.add),
              label: const Text("Agregar Nota"),
              style: ElevatedButton.styleFrom(
                // Usa el primary del theme (Naranja)
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppFooter(
        currentIndex: 1,
        onTap: (index) => print("Navegando al índice: $index"),
      ),
    );
  }
}