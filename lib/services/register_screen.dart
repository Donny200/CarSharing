import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  final _secureStorage = const FlutterSecureStorage();
  String gender = 'Male';
  bool isLoading = false;

  static const String baseUrl = 'https://we-uh-finishing-latest.trycloudflare.com';

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
      ).timeout(const Duration(seconds: 10));

      debugPrint('Register response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['accessToken'] != null) {
          await _secureStorage.write(key: 'accessToken', value: data['accessToken']);
          debugPrint('Token stored in secure storage: ${data['accessToken']}');
          return true;
        } else {
          debugPrint('No accessToken in response');
          return false;
        }
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.tr('register'), style: theme.textTheme.headlineMedium),
        backgroundColor: theme.primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: loc.tr('email'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: theme.inputDecorationTheme.fillColor,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || value.isEmpty ? loc.tr('fill_email') : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: loc.tr('phone'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.phone_outlined),
                  filled: true,
                  fillColor: theme.inputDecorationTheme.fillColor,
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? loc.tr('fill_phone') : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: loc.tr('first_name'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: theme.inputDecorationTheme.fillColor,
                ),
                validator: (value) => value == null || value.isEmpty ? loc.tr('fill_name') : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: loc.tr('last_name'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: theme.inputDecorationTheme.fillColor,
                ),
                validator: (value) => value == null || value.isEmpty ? loc.tr('fill_lastname') : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: birthDateController,
                decoration: InputDecoration(
                  labelText: loc.tr('birth_date'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.calendar_today),
                  filled: true,
                  fillColor: theme.inputDecorationTheme.fillColor,
                ),
                readOnly: true,
                onTap: _selectDate,
                validator: (value) => value == null || value.isEmpty ? loc.tr('choose_birthdate') : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: gender == 'Male' ? loc.tr('male') : loc.tr('female'),
                items: [
                  DropdownMenuItem(value: loc.tr('male'), child: Text(loc.tr('male'))),
                  DropdownMenuItem(value: loc.tr('female'), child: Text(loc.tr('female'))),
                ],
                onChanged: (value) => setState(() => gender = value == loc.tr('male') ? 'Male' : 'Female'),
                decoration: InputDecoration(
                  labelText: loc.tr('gender'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: theme.inputDecorationTheme.fillColor,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: loc.tr('password'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.lock_outline),
                  filled: true,
                  fillColor: theme.inputDecorationTheme.fillColor,
                ),
                validator: (value) => value == null || value.isEmpty ? loc.tr('fill_password') : null,
              ),
              const SizedBox(height: 32),
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
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                  ),
                  child: isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(loc.tr('register'), style: const TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}