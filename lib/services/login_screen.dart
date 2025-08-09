import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/localization_service.dart';
import '../screens/car_map_screen.dart';

class LoginScreen extends StatefulWidget {
  final String email;

  const LoginScreen({super.key, required this.email});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  bool isLoading = false;

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
      return false;
    } else {
      throw Exception('Ошибка сервера: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = Provider.of<LocalizationService>(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.tr('login_or_register'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('${loc.tr('email')}: ${widget.email}'),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: loc.tr('phone')),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: loc.tr('password')),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                  setState(() => isLoading = true);
                  try {
                    final success = await login(phoneController.text.trim(), passwordController.text.trim());
                    if (success) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CarMapScreen()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.tr('invalid_credentials'))));
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc.tr('signin_error')}: $e')));
                  } finally {
                    setState(() => isLoading = false);
                  }
                },
                child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Войти'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
