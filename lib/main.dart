import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/theme_notifier.dart';
import 'services/auth_start_screen.dart';
import 'screens/car_map_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
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
      return const CarMapScreen(); // пользователь уже вошёл
    } else {
      return const AuthStartScreen(); // требует входа
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (_, themeNotifier, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeNotifier.currentTheme,
          home: FutureBuilder<Widget>(
            future: _getStartScreen(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return const Scaffold(
                  body: Center(child: Text('Ошибка при загрузке')),
                );
              } else {
                return snapshot.data!;
              }
            },
          ),
        );
      },
    );
  }
}
