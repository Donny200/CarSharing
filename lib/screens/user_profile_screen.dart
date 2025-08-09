import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/localization_service.dart';

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
      if (token == null) throw Exception('Token not found');

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
        final profile = data is Map<String, dynamic> && data.containsKey('data') ? data['data'] : data;
        setState(() {
          profileData = profile;
          _loading = false;
        });
      } else {
        throw Exception('Ошибка ${response.statusCode}');
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
    final loc = Provider.of<LocalizationService>(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.tr('profile'))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildProfileItem(loc.tr('first_name'), profileData['firstName']),
            _buildProfileItem(loc.tr('last_name'), profileData['lastName']),
            _buildProfileItem('Username', profileData['username']),
            _buildProfileItem(loc.tr('email'), profileData['email']),
            _buildProfileItem(loc.tr('phone'), profileData['phoneNumber']),
            _buildProfileItem(loc.tr('birth_date'), profileData['birthDate']),
            _buildProfileItem('Gender', profileData['gender']),
          ],
        ),
      ),
    );
  }
}
