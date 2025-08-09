import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme/theme_notifier.dart';
import 'services/localization_service.dart';
import 'services/auth_start_screen.dart';
import 'screens/car_map_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => LocalizationService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getStartScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token != null && token.isNotEmpty) {
      return const CarMapScreen();
    } else {
      return const AuthStartScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final loc = Provider.of<LocalizationService>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: loc.tr('app_title'),
      theme: themeNotifier.currentTheme,
      home: FutureBuilder<Widget>(
        future: _getStartScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasError) {
            return Scaffold(body: Center(child: Text(snapshot.error.toString())));
          } else {
            return snapshot.data!;
          }
        },
      ),
    );
  }
}
