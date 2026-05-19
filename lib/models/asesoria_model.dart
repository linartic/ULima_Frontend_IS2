import 'package:ulima_plus/models/docente_model.dart';

class Asesoria {

  final String id;
  final String cursoId;
  final String curso;
  final Docente docente;
  final String dia;
  final String inicio;
  final String fin;
  final String aula;
  final String zoom;

  Asesoria({
    required this.id,
    required this.cursoId,
    required this.curso,
    required this.docente,
    required this.dia,
    required this.inicio,
    required this.fin,
    required this.aula,
    required this.zoom,
  });

  factory Asesoria.fromJson(
    Map<String,dynamic> json,
  ) {

    return Asesoria(
      id: json['id'],
      cursoId: json['cursoId'],
      curso: json['curso'],

      docente: Docente.fromJson(json['docente']),

      dia: json['dia'],
      inicio: json['inicio'],
      fin: json['fin'],
      aula: json['aula'],
      zoom: json['zoom'],
    );
  }
}