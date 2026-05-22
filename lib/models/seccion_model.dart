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

  // Convierte JSON a objeto con protección anti-nulos
  factory Seccion.fromJson(Map<String, dynamic> json) {
    return Seccion(
      idSeccion: json['idSeccion']?.toString() ?? '',
      codigoSeccion: json['codigoSeccion']?.toString() ?? '',
      promedioSeccion: (json['promedioSeccion'] as num?)?.toDouble() ?? 0.0,
      idCurso: json['idCurso']?.toString() ?? '',
      curso: json['curso']?.toString() ?? 'Sin curso',
      
      // PROTECCIÓN: Si 'docente' es null, pasamos un mapa vacío para que no falle
      docente: Docente.fromJson(json['docente'] ?? {}),
      
      asistido: (json['asistido'] as num?)?.toInt() ?? 0,
      inasistencia: (json['inasistencia'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}