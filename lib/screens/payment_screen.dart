import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'payment_methods_screen.dart';
import '../services/localization_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int? selectedAmount;
  final TextEditingController customAmountController = TextEditingController();

  void goToMethodsScreen(int amount) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentMethodsScreen(amount: amount)));
  }

  @override
  Widget build(BuildContext context) {
    final loc = Provider.of<LocalizationService>(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.tr('payment'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(loc.tr('choose_amount')),
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
            Text(loc.tr('or_enter_amount')),
            const SizedBox(height: 8),
            TextField(
              controller: customAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: '8000'),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final entered = int.tryParse(customAmountController.text);
                  if (entered != null && entered > 0) {
                    goToMethodsScreen(entered);
                  }
                },
                child: Text(loc.tr('continue')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
