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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.tr('payment'), style: theme.textTheme.headlineMedium),
        backgroundColor: theme.primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.tr('choose_amount'), style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (var amount in [5000, 10000, 15000])
                  ChoiceChip(
                    label: Text('$amount сум', style: const TextStyle(fontWeight: FontWeight.bold)),
                    selected: selectedAmount == amount,
                    onSelected: (_) {
                      setState(() => selectedAmount = amount);
                      goToMethodsScreen(amount);
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.teal,
                    labelStyle: TextStyle(color: selectedAmount == amount ? Colors.white : Colors.black),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            Text(loc.tr('or_enter_amount'), style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: customAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '8000',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.attach_money),
                filled: true,
                fillColor: theme.inputDecorationTheme.fillColor,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final entered = int.tryParse(customAmountController.text);
                  if (entered != null && entered > 0) {
                    goToMethodsScreen(entered);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: Text(loc.tr('continue'), style: const TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}