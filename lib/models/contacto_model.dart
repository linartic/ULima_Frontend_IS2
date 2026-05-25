import 'package:ulima_plus/models/user_model.dart';

class ContactoCurso {
  final UserModel user;
  final String roleInSection;

  ContactoCurso({required this.user, required this.roleInSection});

  void operator [](String other) {}
}
