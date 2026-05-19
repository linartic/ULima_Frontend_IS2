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

  // Convierte JSON a objeto
  factory Docente.fromJson(
    Map<String,dynamic> json,
  ) {

    return Docente(
      code:json['code'],
      firstName: json['firstName'],
      lastName:json['lastName'],
    );
  }
}