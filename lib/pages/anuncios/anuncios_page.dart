// lib/pages/anuncios/anuncios_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../descripCursos/descrip_cursos.dart';

import 'anuncios_controller.dart';

class AnunciosPage extends StatelessWidget {

  AnunciosController control =
      Get.put(AnunciosController());

  AnunciosPage({super.key});

  @override
  Widget build(BuildContext context) {

    control.context = context;

    return DescripCursosPage();
  }
}