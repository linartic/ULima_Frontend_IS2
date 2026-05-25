import 'package:ulima_plus/models/user_model.dart';

class Anuncio {
  final String id;
  final String idSeccion;
  final String titulo;
  final String mensaje;
  final String fecha;
  final String autorCode;
  final UserModel autor;

  Anuncio({
    required this.id,
    required this.idSeccion,
    required this.titulo,
    required this.mensaje,
    required this.fecha,
    required this.autorCode,
    required this.autor,
  });

  factory Anuncio.fromJson(
    Map<String, dynamic> json, {
    required UserModel autor,
  }) {
    return Anuncio(
      id: json['id'].toString(),
      idSeccion: json['idSeccion'].toString(),
      titulo: json['titulo'].toString(),
      mensaje: json['mensaje'].toString(),
      fecha: json['fecha'].toString(),
      autorCode: json['autorCode'].toString(),
      autor: autor,
    );
  }
}
