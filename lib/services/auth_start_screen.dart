import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
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
      final url = Uri.parse('https://e62ec121a076.ngrok-free.app/auth/signin-byemail');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'phoneNumber': ''}),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Timeout');
      });

      final data = jsonDecode(response.body ?? '{}');

      if (response.statusCode == 200 && data['accessToken'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', data['accessToken']);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CarMapScreen()));
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.tr('invalid_credentials'))));
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.tr('user_not_found'))));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.tr('server_error', {'code': response.statusCode.toString()}))));
      }
    } catch (e) {
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
    return Scaffold(
      appBar: AppBar(title: Text(loc.tr('login_or_register')) , actions: const []),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: loc.tr('email')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: loc.tr('password')),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _loginOrRegister,
                child: isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(loc.tr('continue')),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(onPressed: _navigateToRegister, child: Text(loc.tr('no_account'))),
          ],
        ),
      ),
    );
  }
}
