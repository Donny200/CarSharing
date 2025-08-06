import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carsharing/theme/theme_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_start_screen.dart'; // Импорт экрана авторизации

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');

    // Переход на экран входа без возможности возврата назад
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthStartScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: const Text('Тёмная тема'),
            value: themeNotifier.isDark,
            onChanged: (_) => themeNotifier.toggleTheme(),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Выйти из аккаунта'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
