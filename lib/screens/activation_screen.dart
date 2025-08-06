import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:carsharing/screens/car_map_screen.dart';

class ActivationScreen extends StatefulWidget {
  final String email;
  const ActivationScreen({super.key, required this.email});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final codeController = TextEditingController();
  bool isLoading = false;

  static const String baseUrl = 'https://e62ec121a076.ngrok-free.app';

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

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Аккаунт успешно активирован')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CarMapScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Неверный код активации')),
        );
      }
    } catch (e) {
      debugPrint('Ошибка активации: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка соединения с сервером')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Активация аккаунта')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Код был отправлен на: ${widget.email}'),
            const SizedBox(height: 20),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: 'Код активации'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : activateAccount,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Подтвердить'),
            ),
          ],
        ),
      ),
    );
  }
}
