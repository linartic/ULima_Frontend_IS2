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

  factory Asesoria.fromJson(Map<String, dynamic> json) {
    return Asesoria(
      id: json['id']?.toString() ?? '',
      cursoId: json['cursoId']?.toString() ?? '',
      curso: json['curso']?.toString() ?? 'Sin curso',
      
      docente: Docente.fromJson(json['docente'] ?? {}),
      
      dia: json['dia']?.toString() ?? 'Por definir',
      inicio: json['inicio']?.toString() ?? '',
      fin: json['fin']?.toString() ?? '',
      aula: json['aula']?.toString() ?? 'Por definir',
      zoom: json['zoom']?.toString() ?? '',
    );
  }
}