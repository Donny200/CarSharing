import 'dart:convert';
import 'package:carsharing/services/auth_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/localization_service.dart';
import '../services/register_screen.dart';
import '../screens/car_map_screen.dart';

class AuthStartScreen extends StatefulWidget {
  const AuthStartScreen({super.key});

  @override
  State<AuthStartScreen> createState() => _AuthStartScreenState();
}

class _AuthStartScreenState extends State<AuthStartScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _secureStorage = const FlutterSecureStorage();
  bool isLoading = false;

  Future<void> _loginOrRegister() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final loc = Provider.of<LocalizationService>(context, listen: false);

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.tr('enter_email_password'))));
      return;
    }

    setState(() => isLoading = true);

    try {
      final url = Uri.parse('https://norway-org-newark-sizes.trycloudflare.com/auth/signin-byemail');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'phoneNumber': ''}),
      ).timeout(const Duration(seconds: 10));

      debugPrint('AuthStart response: ${response.statusCode} ${response.body}');

      final data = jsonDecode(response.body ?? '{}');

      if (response.statusCode == 200 && data['accessToken'] != null) {
        await AuthStorage().saveToken(data['accessToken'] as String);  // <-- сохраняем
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CarMapScreen()));
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.tr('invalid_credentials'))));
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.tr('user_not_found'))));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.tr('server_error', {'code': response.statusCode.toString()}))));
      }
    } catch (e) {
      debugPrint('AuthStart error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc.tr('signin_error')}: ${e.toString()}')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _navigateToRegister() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
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
                  child: TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: loc.tr('email'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      prefixIcon: const Icon(Icons.email_outlined),
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
                    onPressed: isLoading ? null : _loginOrRegister,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 10,
                      shadowColor: theme.primaryColor.withOpacity(0.5),
                    ),
                    child: isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(loc.tr('continue'), style: const TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _navigateToRegister,
                  child: Text(loc.tr('no_account'), style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}