import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carsharing/screens/car_map_screen.dart';

class RegisterScreen extends StatelessWidget {
  final String email;

  const RegisterScreen({super.key, required this.email});

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String phone,
    required String gender,
  }) async {
    final url = Uri.parse('http://053c2a07ed73.ngrok-free.app/auth/signup');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'phoneNumber': phone,
        'gender': gender,
        'appName': 'CarSharingApp',
      }),
    );
    return response.statusCode == 200;
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final genderController = TextEditingController(text: 'Мужчина');
    final passwordController = TextEditingController();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final phoneController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              Text('Email: $email'),
              TextFormField(controller: phoneController, decoration: const InputDecoration(labelText: 'Телефон')),
              TextFormField(controller: firstNameController, decoration: const InputDecoration(labelText: 'Имя')),
              TextFormField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Фамилия')),
              DropdownButtonFormField<String>(
                value: 'Мужчина',
                items: ['Мужчина', 'Женщина']
                    .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                    .toList(),
                onChanged: (value) => genderController.text = value!,
                decoration: const InputDecoration(labelText: 'Пол'),
              ),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Пароль'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final success = await register(
                      username: '${firstNameController.text} ${lastNameController.text}',
                      email: email,
                      password: passwordController.text,
                      phone: phoneController.text.trim(),
                      gender: genderController.text,
                    );
                    if (success) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const CarMapScreen()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ошибка регистрации')),
                      );
                    }
                  }
                },
                child: const Text('Зарегистрироваться'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
