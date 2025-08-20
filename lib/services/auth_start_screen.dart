import 'dart:convert';
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
      final url = Uri.parse('https://we-uh-finishing-latest.trycloudflare.com/auth/signin-byemail');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'phoneNumber': ''}),
      ).timeout(const Duration(seconds: 10));

      debugPrint('AuthStart response: ${response.statusCode} ${response.body}');

      final data = jsonDecode(response.body ?? '{}');

      if (response.statusCode == 200 && data['accessToken'] != null) {
        await _secureStorage.write(key: 'accessToken', value: data['accessToken']);
        debugPrint('Token stored in secure storage: ${data['accessToken']}');
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
      appBar: AppBar(
        title: Text(loc.tr('login_or_register'), style: theme.textTheme.headlineMedium),
        backgroundColor: theme.primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: loc.tr('email'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: theme.inputDecorationTheme.fillColor,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: loc.tr('password'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.lock_outline),
                filled: true,
                fillColor: theme.inputDecorationTheme.fillColor,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _loginOrRegister,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
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
    );
  }
}