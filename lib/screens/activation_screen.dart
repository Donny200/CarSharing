import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';
import 'car_map_screen.dart';

class ActivationScreen extends StatefulWidget {
  final String email;
  const ActivationScreen({super.key, required this.email});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final codeController = TextEditingController();
  bool isLoading = false;

  static const String baseUrl = 'https://we-uh-finishing-latest.trycloudflare.com';

  Future<void> activateAccount() async {
    setState(() => isLoading = true);
    try {
      final now = DateTime.now();
      final formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now);

      final url = Uri.parse('$baseUrl/auth/activate');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'code': codeController.text.trim(),
          'date': formattedDate,
        }),
      );

      debugPrint('Ответ сервера: ${response.statusCode} ${response.body}');

      final loc = Provider.of<LocalizationService>(context, listen: false);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.tr('account_activated'))),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CarMapScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.tr('invalid_code'))),
        );
      }
    } catch (e) {
      debugPrint('Ошибка активации: $e');
      final loc = Provider.of<LocalizationService>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.tr('connection_error'))),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = Provider.of<LocalizationService>(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.tr('activate_account'), style: theme.textTheme.headlineMedium),
        backgroundColor: theme.primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loc.tr('code_sent_to', {'email': widget.email}),
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: loc.tr('activation_code'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.lock_outline),
                filled: true,
                fillColor: theme.inputDecorationTheme.fillColor,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : activateAccount,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 5,
              ),
              child: isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(loc.tr('confirm'), style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}