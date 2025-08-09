import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';
import '../screens/activation_screen.dart';

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
  String gender = 'Male';

  static const String baseUrl = 'https://e62ec121a076.ngrok-free.app';
  bool isLoading = false;

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
        'gender': gender,
        'app': 'HAYDA',
      };

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
    final loc = Provider.of<LocalizationService>(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.tr('register'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: loc.tr('email')),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || value.isEmpty ? loc.tr('fill_email') : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: loc.tr('phone')),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? loc.tr('fill_phone') : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: loc.tr('first_name')),
                validator: (value) => value == null || value.isEmpty ? loc.tr('fill_name') : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: loc.tr('last_name')),
                validator: (value) => value == null || value.isEmpty ? loc.tr('fill_lastname') : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: birthDateController,
                decoration: InputDecoration(labelText: loc.tr('birth_date')),
                readOnly: true,
                onTap: _selectDate,
                validator: (value) => value == null || value.isEmpty ? loc.tr('choose_birthdate') : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: gender == 'Male' ? loc.tr('male') : loc.tr('female'),
                items: [
                  DropdownMenuItem(value: loc.tr('male'), child: Text(loc.tr('male'))),
                  DropdownMenuItem(value: loc.tr('female'), child: Text(loc.tr('female'))),
                ],
                onChanged: (value) => setState(() => gender = value == loc.tr('male') ? 'Male' : 'Female'),
                decoration: InputDecoration(labelText: loc.tr('select_language')),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: loc.tr('password')),
                validator: (value) => value == null || value.isEmpty ? loc.tr('fill_password') : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                    if (formKey.currentState!.validate()) {
                      setState(() => isLoading = true);
                      final success = await register();
                      setState(() => isLoading = false);
                      if (success) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => ActivationScreen(email: emailController.text.trim())),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.tr('registration_error'))));
                      }
                    }
                  },
                  child: isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(loc.tr('register')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
