class Delegado {

  final int id;

  final String nombre;
  final String rol;

  Delegado({
    required this.id,
    required this.nombre,
    required this.rol,
  });

  factory Delegado.fromJson(
      Map<String, dynamic> json) {

    return Delegado(

      id: json['id'],

      nombre: json['nombre'],

      rol: json['rol'],
    );
  }
}