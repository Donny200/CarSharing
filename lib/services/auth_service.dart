import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carsharing/services/login_screen.dart';
import 'package:carsharing/services/register_screen.dart';
import 'package:http/http.dart' as http;

class AuthStartScreen extends StatefulWidget {
  const AuthStartScreen({super.key});

  @override
  State<AuthStartScreen> createState() => _AuthStartScreenState();
}

class _AuthStartScreenState extends State<AuthStartScreen> {
  final emailController = TextEditingController();
  bool isLoading = false;

  Future<void> _checkEmail() async {
    final email = emailController.text.trim();
    if (email.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse('http://053c2a07ed73.ngrok-free.app/auth/checkup');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'phoneNumber': '',
          'username': '',
        }),
      );

      if (response.statusCode == 200) {
        // Email уже существует -> переход на экран входа
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen(email: email)),
        );
      } else {
        // Email не найден -> переход на регистрацию
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RegisterScreen(email: email)),
        );
      }
    } catch (e) {
      debugPrint('Ошибка при проверке email: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка соединения с сервером')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добро пожаловать')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Введите ваш email', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'example@mail.com',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _checkEmail,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Продолжить'),
            ),
          ],
        ),
      ),
    );
  }
}
