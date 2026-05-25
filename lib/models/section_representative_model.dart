//DELEGADOS DE UNA SECCION
class SectionRepresentative {
  final String id;
  final String enrollmentId;
  final String role;

  SectionRepresentative({
    required this.id,
    required this.enrollmentId,
    required this.role,
  });

  factory SectionRepresentative.fromJson(Map<String, dynamic> json) {
    return SectionRepresentative(
      id: json['id'].toString(),
      enrollmentId: json['enrollmentId'].toString(),
      role: json['role'].toString(),
    );
  }
}
