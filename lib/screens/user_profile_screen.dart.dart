import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _loading = true;
  Map<String, dynamic> profileData = {};

  static const String baseUrl = 'https://e62ec121a076.ngrok-free.app';

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<void> _fetchProfile() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Токен не найден. Авторизуйтесь снова.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/profile/get'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Ответ сервера: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final profile = data is Map<String, dynamic> && data.containsKey('data')
            ? data['data']
            : data;

        setState(() {
          profileData = profile;
          _loading = false;
        });
      } else {
        throw Exception('Ошибка загрузки профиля: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Ошибка: $e');
      setState(() => _loading = false);
    }
  }

  Widget _buildProfileItem(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        '$title: ${value ?? ''}',
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildProfileItem('Имя', profileData['firstName']),
            _buildProfileItem('Фамилия', profileData['lastName']),
            _buildProfileItem('Никнейм', profileData['username']),
            _buildProfileItem('Email', profileData['email']),
            _buildProfileItem('Телефон', profileData['phoneNumber']),
            _buildProfileItem('Дата рождения', profileData['birthDate']),
            _buildProfileItem(
                'Пол',
                profileData['gender'] == 'Male'
                    ? 'Мужчина'
                    : profileData['gender'] == 'Female'
                    ? 'Женщина'
                    : profileData['gender']),
          ],
        ),
      ),
    );
  }
}
