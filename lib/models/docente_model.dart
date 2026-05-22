class Docente {
  final String code;
  final String firstName;
  final String lastName;

  Docente({
    required this.code,
    required this.firstName,
    required this.lastName,
  });

  String get fullName => '$firstName $lastName';

  // Convierte JSON a objeto con protección anti-nulos
  factory Docente.fromJson(Map<String, dynamic> json) {
    return Docente(
      code: json['code']?.toString() ?? 'Sin código',
      firstName: json['firstName']?.toString() ?? 'No',
      lastName: json['lastName']?.toString() ?? 'Asignado',
    );
  }
}