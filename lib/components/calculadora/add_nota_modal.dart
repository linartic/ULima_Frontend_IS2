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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un curso')),
      );
      return;
    }

    if (!_validarNota(_notaController.text)) return;

    final controller = Get.find<CalculadoraController>();
    final nota = double.parse(_notaController.text);

    controller.agregarNota(_cursoSeleccionado!, 'Nueva Evaluación', 10, nota);
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CalculadoraController>();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Agregar Nota",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildLabel("Curso"),
          Obx(() {
            final cursos = controller.cursos;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(15)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                  isExpanded: true,
                  hint: const Text("Selecciona un curso"),
                  value: _cursoSeleccionado,
                  items: List.generate(
                    cursos.length,
                    (index) => DropdownMenuItem(
                      value: index,
                      child: Text(
                          "${cursos[index]['id']} - ${cursos[index]['nombre']}"),
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
          _buildLabel("Evaluación"),
          _buildDropdown("Examen Final - 30%"),
          const SizedBox(height: 15),
          // Info Box Azul
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.shade100)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Peso automático:",
                        style: TextStyle(
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.bold)),
                    const Text("Este peso se obtuvo del sílabo del curso",
                        style: TextStyle(color: Colors.blue, fontSize: 11)),
                  ],
                ),
                Text("30%",
                    style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 15),
          _buildLabel("Nota (0-20)"),
          TextField(
            controller: _notaController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              hintText: "Ej: 18",
              hintStyle: TextStyle(color: Colors.grey.shade400),
              errorText: _notaError,
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.red),
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
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      child: const Text("Cancelar"))),
              const SizedBox(width: 15),
              Expanded(
                  child: ElevatedButton(
                      onPressed: _agregarNota,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade800,
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      child: const Text("Agregar"))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: TextStyle(
              fontWeight: FontWeight.w500, color: Colors.grey.shade700)));

  Widget _buildDropdown(String value) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(15)),
        child: DropdownButtonHideUnderline(
            child: DropdownButton(
                isExpanded: true,
                value: value,
                items: [DropdownMenuItem(value: value, child: Text(value))],
                onChanged: (v) {})),
      );
}
