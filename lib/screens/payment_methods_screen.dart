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
    final theme = Theme.of(context);
    final methods = ['Click', 'Payme', 'Hazna'];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(loc.tr('select_payment_method'), style: theme.textTheme.headlineMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.primaryColor.withOpacity(0.8), theme.colorScheme.background],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: methods.map((method) {
              return Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: ListTile(
                  leading: const Icon(Icons.payment, color: Colors.teal, size: 32),
                  title: Text(method, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _processPayment(context, method),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}