class Anuncio {
  final int id;

  final String titulo;
  final String mensaje;
  final String fecha;

  Anuncio({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.fecha,
  });

  factory Anuncio.fromJson(Map<String, dynamic> json) {
    return Anuncio(
      id: json['id'] ?? 0,

      titulo: json['titulo'],

      mensaje: json['mensaje'],

      fecha: json['fecha'],
    );
  }
}
