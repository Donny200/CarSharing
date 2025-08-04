import 'package:flutter/material.dart';
import '../services/user_data.dart';

class PaymentMethodsScreen extends StatelessWidget {
  final int amount;

  const PaymentMethodsScreen({super.key, required this.amount});

  Future<void> _processPayment(BuildContext context, String method) async {
    // тут можно добавить реальную оплату, но пока просто показываем SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Оплата $amount сум через $method выполнена!')),
    );

    await UserDataService.updateBalance(amount);
    await UserDataService.addToHistory('Пополнение $amount сум через $method');

    // вернуться назад через 1 сек
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context); // просто закрываем экран оплаты
    });

  }

  @override
  Widget build(BuildContext context) {
    final methods = ['Click', 'Payme', 'Hazna'];

    return Scaffold(
      appBar: AppBar(title: const Text('Выберите способ оплаты')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: methods.map((method) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.payment),
              title: Text(method),
              onTap: () => _processPayment(context, method),
            ),
          );
        }).toList(),
      ),
    );
  }
}
