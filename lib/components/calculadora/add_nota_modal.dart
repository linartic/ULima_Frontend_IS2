import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../pages/calculadora/calculadora_controller.dart';

class AddNotaModal extends StatefulWidget {
  const AddNotaModal({super.key});

  @override
  State<AddNotaModal> createState() => _AddNotaModalState();
}

class _AddNotaModalState extends State<AddNotaModal> {
  late TextEditingController _notaController;
  String? _notaError;
  int? _cursoSeleccionado;

  @override
  void initState() {
    super.initState();
    _notaController = TextEditingController();
  }

  @override
  void dispose() {
    _notaController.dispose();
    super.dispose();
  }

  bool _validarNota(String valor) {
    if (valor.isEmpty) {
      setState(() => _notaError = 'La nota es requerida');
      return false;
    }

    final nota = double.tryParse(valor);
    if (nota == null) {
      setState(() => _notaError = 'Ingresa un número válido');
      return false;
    }

    if (nota < 0 || nota > 20) {
      setState(() => _notaError = 'La nota debe estar entre 0 y 20');
      return false;
    }

    setState(() => _notaError = null);
    return true;
  }

  void _agregarNota() {
    if (_cursoSeleccionado == null) {
      Get.snackbar(
        'Atención', 
        'Por favor selecciona un curso',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!_validarNota(_notaController.text)) return;

    final controller = Get.find<CalculadoraController>();
    final nota = double.parse(_notaController.text);

    controller.agregarNota(
      _cursoSeleccionado!,
      'Nueva Evaluación',
      10,
      nota,
      '',
    );
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CalculadoraController>();
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface, // Cambia automáticamente a gris oscuro o claro
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Agregar Nota",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.onSurface),
          ),
          const SizedBox(height: 20),
          _buildLabel("Curso", colors),
          Obx(() {
            final cursos = controller.cursos;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: colors.outline.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(15),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                  dropdownColor: colors.surface,
                  isExpanded: true,
                  hint: Text("Selecciona un curso", style: TextStyle(color: colors.onSurfaceVariant.withOpacity(0.6))),
                  value: _cursoSeleccionado,
                  style: TextStyle(color: colors.onSurface),
                  items: List.generate(
                    cursos.length,
                    (index) => DropdownMenuItem(
                      value: index,
                      child: Text("${cursos[index]['id']} - ${cursos[index]['nombre']}"),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _cursoSeleccionado = value);
                  },
                ),
              ),
            );
          }),
          const SizedBox(height: 15),
          _buildLabel("Evaluación", colors),
          _buildDropdown("Examen Final - 30%", colors),
          const SizedBox(height: 15),
          
          // Info Box Adaptable (Ya no es azul estática)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.secondaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: colors.secondary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Peso automático:",
                        style: TextStyle(color: colors.secondary, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Este peso se obtuvo del sílabo del curso",
                        style: TextStyle(color: colors.onSurfaceVariant.withOpacity(0.7), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Text(
                  "30%",
                  style: TextStyle(color: colors.secondary, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          _buildLabel("Nota (0-20)", colors),
          TextField(
            controller: _notaController,
            style: TextStyle(color: colors.onSurface),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: colors.outline.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: colors.primary),
              ),
              hintText: "Ej: 18",
              hintStyle: TextStyle(color: colors.onSurfaceVariant.withOpacity(0.4)),
              errorText: _notaError,
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: colors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: colors.error, width: 2.0),
              ),
            ),
            onChanged: (_) => setState(() => _notaError = null),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.primary,
                    side: BorderSide(color: colors.primary),
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Cancelar"),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  onPressed: _agregarNota,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Agregar"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLabel(String text, ColorScheme colors) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.w500, color: colors.onSurfaceVariant.withOpacity(0.8)),
        ),
      );

  Widget _buildDropdown(String value, ColorScheme colors) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: colors.outline.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(15),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            dropdownColor: colors.surface,
            isExpanded: true,
            value: value,
            style: TextStyle(color: colors.onSurface),
            items: [DropdownMenuItem(value: value, child: Text(value))],
            onChanged: (v) {},
          ),
        ),
      );
}