import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carsharing/screens/car_map_screen.dart';

class LoginScreen extends StatelessWidget {
  final String email;

  const LoginScreen({super.key, required this.email});

  Future<bool> login(String phone, String password) async {
    final url = Uri.parse('https://e62ec121a076.ngrok-free.app/auth/signin');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phoneNumber': phone, 'password': password}),
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      // Неверный пароль или неавторизован
      return false;
    } else {
      throw Exception('Ошибка сервера: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final passwordController = TextEditingController();
    final phoneController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Вход')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Email: $email'),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Телефон'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Пароль'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final success = await login(
                  phoneController.text.trim(),
                  passwordController.text.trim(),
                );
                try {
                  final success = await login(
                    phoneController.text.trim(),
                    passwordController.text.trim(),
                  );
                  if (success) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const CarMapScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Неверный номер телефона или пароль')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка: ${e.toString()}')),
                  );
                }
              },
              child: const Text('Войти'),
            ),
          ],
        ),
      ),
    );
  }
}
