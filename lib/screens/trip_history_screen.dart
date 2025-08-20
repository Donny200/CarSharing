import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  bool _loading = true;
  List<dynamic> _trips = [];

  // Если на сервере другой базовый URL — поправь здесь
  static const String baseUrl = 'https://we-uh-finishing-latest.trycloudflare.com';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    try {
      final token = await _getToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final url = Uri.parse('$baseUrl/trip/history'); // заглушка — реализуй на backend
      final res = await http.get(url, headers: headers).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final jsonBody = jsonDecode(res.body);
        List<dynamic> list;
        if (jsonBody is Map && jsonBody.containsKey('data') && jsonBody['data'] is List) {
          list = jsonBody['data'] as List<dynamic>;
        } else if (jsonBody is List) {
          list = jsonBody;
        } else {
          list = [];
        }

        setState(() {
          _trips = list;
        });
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Требуется авторизация')));
      } else {
        debugPrint('Ошибка истории поездок: ${res.statusCode} ${res.body}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: ${res.statusCode}')));
      }
    } catch (e) {
      debugPrint('Ошибка загрузки истории: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Не удалось загрузить историю')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildTripItem(dynamic t) {
    // ожидаем структуру: { date: "...", carName: "...", distance: 1234, price: 100 }
    final dateRaw = t['date'] ?? t['createdAt'] ?? t['time'];
    final carName = t['carName'] ?? t['vehicle'] ?? t['car'] ?? '—';
    final distance = t['distance'];
    final price = t['price'] ?? t['cost'];

    String dateText = '';
    try {
      if (dateRaw != null) {
        final dt = DateTime.parse(dateRaw.toString());
        dateText = DateFormat.yMMMd().add_jm().format(dt.toLocal());
      }
    } catch (e) {
      dateText = dateRaw?.toString() ?? '';
    }

    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Icon(Icons.history_toggle_off, color: Colors.teal),
        title: Text(carName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text('Дата: $dateText\nДистанция: ${distance ?? '—'} м', style: theme.textTheme.bodyMedium),
        trailing: Text('${price ?? '—'}', style: theme.textTheme.titleMedium?.copyWith(color: Colors.green)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('История поездок', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.primaryColor,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _trips.isEmpty
          ? Center(child: Text('История пуста', style: theme.textTheme.titleLarge))
          : RefreshIndicator(
        onRefresh: _loadHistory,
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _trips.length,
          itemBuilder: (c, i) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildTripItem(_trips[i]),
          ),
        ),
      ),
    );
  }
}