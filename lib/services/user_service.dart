import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/user_model.dart';

class UserService {
  Future<List<UserModel>> fetchUsers() async {
    final String response = await rootBundle.loadString(
      'assets/data/users.json',
    );

    final data = json.decode(response);
    final List users = data['users'];

    return users.map((u) => UserModel.fromJson(u)).toList();
  }

  Future<UserModel?> findUserByCode(String code) async {
    final users = await fetchUsers();

    try {
      return users.firstWhere((u) => u.code == code);
    } catch (e) {
      return null;
    }
  }

  Future<UserModel> findRequiredUserByCode(String code) async {
    final user = await findUserByCode(code);
    if (user == null) {
      throw Exception('No existe un usuario con codigo $code');
    }

    return user;
  }
}
