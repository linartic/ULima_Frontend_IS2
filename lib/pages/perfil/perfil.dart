import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ulima_plus/services/auth_service.dart';
import 'package:ulima_plus/pages/login/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Perfil del Usuario'),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // 1. Ejecutamos el cierre de sesión
              AuthService.to.logout();
              // 2. Redirigimos al usuario a la pantalla de Login y limpiamos la ruta
              Get.offAll(() => const LoginPage());
            },
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}