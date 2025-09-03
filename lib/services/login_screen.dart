import 'dart:convert';
import 'package:carsharing/services/auth_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  final _secureStorage = const FlutterSecureStorage();
  bool isLoading = false;

  Future<bool> login(String phone, String password) async {
    final url = Uri.parse('https://norway-org-newark-sizes.trycloudflare.com/auth/signin');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phone, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      debugPrint('Login response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['accessToken'] != null) {
          await AuthStorage().saveToken(data['accessToken'] as String);  // <-- сохраняем
          return true;
        } else {
          debugPrint('No accessToken in response');
          return false;
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return false;
      } else {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Login error: $e');
      throw Exception('Ошибка входа: $e');
    }

  }

  @override
  Widget build(BuildContext context) {
    final loc = Provider.of<LocalizationService>(context);
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(loc.tr('login_or_register'), style: theme.textTheme.headlineMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.primaryColor.withOpacity(0.8), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  opacity: isLoading ? 0.5 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Text('${loc.tr('email')}: ${widget.email}', style: theme.textTheme.bodyLarge),
                ),
                const SizedBox(height: 16),
                AnimatedOpacity(
                  opacity: isLoading ? 0.5 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: loc.tr('phone'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      prefixIcon: const Icon(Icons.phone_outlined),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedOpacity(
                  opacity: isLoading ? 0.5 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: loc.tr('password'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      prefixIcon: const Icon(Icons.lock_outline),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Hero(
                  tag: 'login_button',
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
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 10,
                      shadowColor: theme.primaryColor.withOpacity(0.5),
                    ),
                    child: isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(loc.tr('login'), style: const TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}