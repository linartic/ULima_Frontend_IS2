// lib/pages/anuncios/anuncios_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnunciosController extends GetxController {

  BuildContext? context;

  RxList<Map<String, dynamic>> anuncios = [

    {
      "titulo": "Abran el BB",

      "descripcion": "miau",

      "profesor": "PEPE - Profesor",

      "fecha": "20/2/2026",
    },

    {
      "titulo": "Cambio de laboratorio",

      "descripcion":
          "Nos vamos al lab de alto rendimiento la semana 20.",

      "profesor": "PEPE - Profesor",

      "fecha": "18/2/2026",
    },

  ].obs;

  void goBack() {
    Navigator.pop(context!);
  }
}