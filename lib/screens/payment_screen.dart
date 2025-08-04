import 'package:flutter/material.dart';
import 'payment_methods_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int? selectedAmount;
  final TextEditingController customAmountController = TextEditingController();

  void goToMethodsScreen(int amount) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentMethodsScreen(amount: amount),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Пополнить баланс')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Выберите сумму для пополнения:'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: [
                for (var amount in [5000, 10000, 15000])
                  ChoiceChip(
                    label: Text('$amount сум'),
                    selected: selectedAmount == amount,
                    onSelected: (_) {
                      setState(() => selectedAmount = amount);
                      goToMethodsScreen(amount);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Или введите свою сумму:'),
            TextField(
              controller: customAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Например, 8000'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final entered = int.tryParse(customAmountController.text);
                if (entered != null && entered > 0) {
                  goToMethodsScreen(entered);
                }
              },
              child: const Text('Продолжить'),
            ),
          ],
        ),
      ),
    );
  }
}
