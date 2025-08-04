import 'package:carsharing/screens/user_profile_screen.dart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carsharing/theme/theme_notifier.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Тёмная тема'),
            value: themeNotifier.isDark,
            onChanged: (_) => themeNotifier.toggleTheme(),
          ),
        ],
      ),
    );
  }
}