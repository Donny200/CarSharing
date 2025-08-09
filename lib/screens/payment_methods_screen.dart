import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_data.dart';
import '../services/localization_service.dart';

class PaymentMethodsScreen extends StatelessWidget {
  final int amount;

  const PaymentMethodsScreen({super.key, required this.amount});

  Future<void> _processPayment(BuildContext context, String method) async {
    final loc = Provider.of<LocalizationService>(context, listen: false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.tr('payment_done', {'amount': amount.toString(), 'method': method}))),
    );

    await UserDataService.updateBalance(amount);
    await UserDataService.addToHistory('Пополнение $amount сум через $method');

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context); // закрываем экран оплаты
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = Provider.of<LocalizationService>(context);
    final methods = ['Click', 'Payme', 'Hazna'];

    return Scaffold(
      appBar: AppBar(title: Text(loc.tr('select_payment_method'))),
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
