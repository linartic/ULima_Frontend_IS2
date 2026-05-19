import 'package:ulima_plus/models/user_model.dart';


class Anuncio {

  final String id;
  final String cursoId;
  final String titulo;
  final String mensaje;
  final String fecha;


  final UserModel autor;

  Anuncio({
    required this.id,
    required this.cursoId,
    required this.titulo,
    required this.mensaje,
    required this.fecha,
    required this.autor,
  });

  factory Anuncio.fromJson(
    Map<String,dynamic> json,
  ) {

    return Anuncio(
      id: json['id'],
      cursoId: json['cursoId'],
      titulo: json['titulo'],
      mensaje: json['mensaje'],
      fecha: json['fecha'],

      autor: UserModel.fromJson(
        json['autor'],
      ),
    );
  }
}