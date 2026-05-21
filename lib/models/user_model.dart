// lib/models/user_model.dart
// Modelo del alumno autenticado en la app.

import 'malla_models.dart';

class UserModel {
  final String code;
  final String firstName;
  final String lastName;
  final String email;
  final String role; // estudiante | delegado | subdelegado
  String? career;
  List<String> especialidades;
  final String currentCycle;
  bool setupComplete;
  CourseProgress? courseProgress;

  UserModel({
    required this.code,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.career,
    List<String>? especialidades,
    required this.currentCycle,
    required this.setupComplete,
    this.courseProgress,
  }) : especialidades = especialidades ?? <String>[];

  String get fullName => '$lastName $firstName ';

  bool get isDelegate => role == 'delegado' || role == 'subdelegado';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      code: json['code'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'estudiante',
      career: json['career'] as String?,
      especialidades: (json['especialidades'] as List?)?.cast<String>() ?? <String>[],
      currentCycle: json['currentCycle'] as String? ?? '2026-1',
      setupComplete: json['setupComplete'] as bool? ?? false,
      courseProgress: CourseProgress.fromJson(
        json['courseProgress'] as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'role': role,
        'career': career,
        'especialidades': especialidades,
        'currentCycle': currentCycle,
        'setupComplete': setupComplete,
      };
}
