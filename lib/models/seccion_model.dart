import 'anuncio_model.dart';
import 'delegado_model.dart';

class Seccion {
  final String id;

  final String curso;
  final String codigo;
  final String docente;
  final Delegado delegado;

  final int presentes;
  final int ausentes;
  final int total;

  final List<Anuncio> anuncios;

  Seccion({
    required this.id,
    required this.curso,
    required this.codigo,
    required this.docente,
    required this.delegado,
    required this.presentes,
    required this.ausentes,
    required this.total,
    required this.anuncios,
  });

  factory Seccion.fromJson(Map<String, dynamic> json) {
    return Seccion(
      id: json['id'],
      curso: json['curso'],
      codigo: json['seccion'],
      docente: json['docente'],
      delegado: Delegado.fromJson(json['delegado']),
      presentes: json['presentes'],
      ausentes: json['ausentes'],
      total: json['total'],
      anuncios: (json['anuncios'] as List<dynamic>? ?? [])
          .map((a) => Anuncio.fromJson(a))
          .toList(),
    );
  }
}
