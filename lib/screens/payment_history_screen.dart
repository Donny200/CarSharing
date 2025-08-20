import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_data.dart';
import '../services/localization_service.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = Provider.of<LocalizationService>(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.tr('payment_history'), style: theme.textTheme.headlineMedium),
        backgroundColor: theme.primaryColor,
        elevation: 0,
      ),
      body: FutureBuilder<List<String>>(
        future: UserDataService.getPaymentHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.isEmpty) return Center(child: Text(loc.tr('empty_history'), style: theme.textTheme.titleLarge));
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: snapshot.data!.map((e) => Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(Icons.receipt, color: Colors.teal),
                title: Text(e, style: theme.textTheme.bodyLarge),
              ),
            )).toList(),
          );
        },
      ),
    );
  }
}