import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/anuncio_model.dart';
import 'user_service.dart';

class AnuncioService {
  final UserService _userService = UserService();

  Future<List<Anuncio>> fetchAnuncios(String idSeccion) async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/anuncios.json',
      );
      final data = json.decode(response);
      final List<dynamic> anunciosRaw = data['anuncios'] ?? [];

      final filtrados = anunciosRaw
          .where((a) => a['idSeccion'].toString() == idSeccion)
          .toList();

      final List<Anuncio> anuncios = [];

      for (final a in filtrados) {
        final autor = await _userService.findRequiredUserByCode(
          a['autorCode'].toString(),
        );

        anuncios.add(Anuncio.fromJson(a, autor: autor));
      }

      return anuncios;
    } catch (e) {
      debugPrint('Error cargando anuncios: $e');
      return [];
    }
  }
}
