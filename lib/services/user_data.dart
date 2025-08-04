import 'package:shared_preferences/shared_preferences.dart';

class UserDataService {
  static Future<int> getBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('balance') ?? 0;
  }

  static Future<void> updateBalance(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('balance') ?? 0;
    await prefs.setInt('balance', current + amount);
  }

  static Future<void> deductFromBalance(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('balance') ?? 0;
    await prefs.setInt('balance', current - amount);
  }

  static Future<List<String>> getPaymentHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('paymentHistory') ?? [];
  }

  static Future<void> addToHistory(String entry) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('paymentHistory') ?? [];
    history.add(entry);
    await prefs.setStringList('paymentHistory', history);
  }
}
