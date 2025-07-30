import 'package:flutter/material.dart';
import 'car_map_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CarMapScreen()),
            );
          },
          child: const Text('Зарегистрироваться'),
        ),
      ),
    );
  }
}
