import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carsharing/screens/activation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final birthDateController = TextEditingController();
  String gender = 'Мужчина';

  static const String baseUrl = 'https://e62ec121a076.ngrok-free.app';

  Future<bool> register() async {
    try {
      final url = Uri.parse('$baseUrl/auth/signup');
      final body = {
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'username': '${firstNameController.text.trim()} ${lastNameController.text.trim()}',
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
        'birthDate': birthDateController.text.trim(),
        'gender': gender == 'Мужчина' ? 'Male' : 'Female',
        'app': 'HAYDA',
      };

      debugPrint('Отправка запроса на $url с данными: $body');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint('Ответ сервера: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['accessToken'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', data['accessToken']);
        }
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Ошибка при регистрации: $e');
      return false;
    }
  }


  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        birthDateController.text = pickedDate.toIso8601String();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                value == null || value.isEmpty ? 'Введите email' : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Телефон'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                value == null || value.isEmpty ? 'Введите телефон' : null,
              ),
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'Имя'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Введите имя' : null,
              ),
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Фамилия'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Введите фамилию' : null,
              ),
              TextFormField(
                controller: birthDateController,
                decoration: const InputDecoration(labelText: 'Дата рождения'),
                readOnly: true,
                onTap: _selectDate,
                validator: (value) =>
                value == null || value.isEmpty ? 'Выберите дату рождения' : null,
              ),
              DropdownButtonFormField<String>(
                value: gender,
                items: const [
                  DropdownMenuItem(value: 'Мужчина', child: Text('Мужчина')),
                  DropdownMenuItem(value: 'Женщина', child: Text('Женщина')),
                ],
                onChanged: (value) =>
                    setState(() => gender = value ?? 'Мужчина'),
                decoration: const InputDecoration(labelText: 'Пол'),
              ),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Пароль'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Введите пароль' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final success = await register();
                    if (success) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ActivationScreen(
                              email: emailController.text.trim()),
                        ),
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
