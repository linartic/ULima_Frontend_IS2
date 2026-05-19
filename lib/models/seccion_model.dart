import 'package:ulima_plus/models/docente_model.dart';

class Seccion {

  final String idSeccion;
  final String codigoSeccion;
  final double promedioSeccion;
  final String idCurso;
  final String curso;
  final Docente docente;
  final int asistido;
  final int inasistencia;
  final int total;

  Seccion({
    required this.idSeccion,
    required this.codigoSeccion,
    required this.promedioSeccion,
    required this.idCurso,
    required this.curso,
    required this.docente,
    required this.asistido,
    required this.inasistencia,
    required this.total,
  });

  // Convierte JSON a objeto
  factory Seccion.fromJson(Map<String,dynamic> json,) {

    return Seccion(

      idSeccion:json['idSeccion'],

      codigoSeccion:json['codigoSeccion'],

      promedioSeccion: (json['promedioSeccion'] as num).toDouble(),

      idCurso:json['idCurso'],
      curso:json['curso'],

      docente: Docente.fromJson(json['docente']),

      asistido:json['asistido'],

      inasistencia:json['inasistencia'],

      total: json['total'],
    );
  }
}