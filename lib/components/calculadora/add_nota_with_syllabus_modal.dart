import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/evaluation_model.dart';
import '../../pages/calculadora/calculadora_controller.dart';

class AddNotaWithSyllabusModal extends StatefulWidget {
  final int cursoIndex;
  final Map cursoData;

  const AddNotaWithSyllabusModal({
    super.key,
    required this.cursoIndex,
    required this.cursoData,
  });

  @override
  State<AddNotaWithSyllabusModal> createState() =>
      _AddNotaWithSyllabusModalState();
}

class _AddNotaWithSyllabusModalState extends State<AddNotaWithSyllabusModal> {
  late TextEditingController _valorController;
  EvaluationComponent? _evaluacionSeleccionada;
  String? _valorError;
  late List<EvaluationComponent> _evaluacionesDisponibles;

  @override
  void initState() {
    super.initState();
    _valorController = TextEditingController();

    // Obtenemos las evaluaciones que NO se han registrado aún
    final controller = Get.find<CalculadoraController>();
    _evaluacionesDisponibles = controller.getAvailableEvaluations(
      widget.cursoIndex,
    );
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  bool _validarValor(String valor) {
    if (valor.isEmpty) {
      setState(() => _valorError = 'La nota es requerida');
      return false;
    }

    final nota = double.tryParse(valor);
    if (nota == null) {
      setState(() => _valorError = 'Ingresa un número válido');
      return false;
    }

    if (nota < 0 || nota > 20) {
      setState(() => _valorError = 'La nota debe estar entre 0 y 20');
      return false;
    }

    setState(() => _valorError = null);
    return true;
  }

  void _agregarNota() {
    if (_evaluacionSeleccionada == null) {
      Get.snackbar(
        'Atención',
        'Por favor selecciona una evaluación',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Theme.of(context).colorScheme.surface,
        colorText: Theme.of(context).colorScheme.onSurface,
      );
      return;
    }

    if (!_validarValor(_valorController.text)) return;

    final controller = Get.find<CalculadoraController>();
    final valor = double.parse(_valorController.text);

    // Guardar la nota
    controller.agregarNota(
      widget.cursoIndex,
      _evaluacionSeleccionada!.nombre,
      _evaluacionSeleccionada!.peso.toInt(),
      valor,
      _evaluacionSeleccionada!.id,
    );

    Get.snackbar(
      'Éxito',
      '${_evaluacionSeleccionada!.sigla} registrada',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade700,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final primary = colors.primary;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Registrar Nota',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                        Text(
                          widget.cursoData['nombre'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.onSurface),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text(
                'Evaluación (del Sílabo)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              if (_evaluacionesDisponibles.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.secondaryContainer.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.outline.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: colors.secondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Todas las evaluaciones han sido registradas',
                          style: TextStyle(color: colors.secondary),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.outline.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<EvaluationComponent>(
                      dropdownColor: colors.surface,
                      isExpanded: true,
                      hint: Text(
                        'Selecciona una evaluación',
                        style: TextStyle(
                          color: colors.onSurfaceVariant.withOpacity(0.6),
                        ),
                      ),
                      value: _evaluacionSeleccionada,
                      style: TextStyle(color: colors.onSurface, fontSize: 14),
                      items: _evaluacionesDisponibles.map((evaluacion) {
                        return DropdownMenuItem(
                          value: evaluacion,
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  evaluacion.sigla,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      evaluacion.nombre,
                                      style: const TextStyle(fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Peso: ${evaluacion.peso.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (evaluacion) {
                        setState(() => _evaluacionSeleccionada = evaluacion);
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              if (_evaluacionSeleccionada != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: primary, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Peso automático:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: primary,
                              ),
                            ),
                            Text(
                              '${_evaluacionSeleccionada!.peso.toStringAsFixed(1)}% (del sílabo del curso)',
                              style: TextStyle(
                                fontSize: 11,
                                color: primary.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              if (_evaluacionesDisponibles.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nota (0 - 20)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _valorController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: TextStyle(color: colors.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Ej: 15.5',
                        hintStyle: TextStyle(
                          color: colors.onSurfaceVariant.withOpacity(0.6),
                        ),
                        errorText: _valorError,
                        errorStyle: TextStyle(color: colors.error),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colors.outline.withOpacity(0.5),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colors.outline.withOpacity(0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onChanged: (_) => setState(() => _valorError = null),
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: colors.outline.withOpacity(0.5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: colors.onSurface),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _evaluacionesDisponibles.isNotEmpty
                          ? _agregarNota
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: colors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: primary.withOpacity(0.3),
                      ),
                      child: const Text(
                        'Registrar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
