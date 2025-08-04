import 'package:flutter/material.dart';
import '../services/user_data.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('История оплат')),
      body: FutureBuilder<List<String>>(
        future: UserDataService.getPaymentHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.isEmpty) return const Center(child: Text('История пуста'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: snapshot.data!.map((e) => ListTile(title: Text(e))).toList(),
          );
        },
      ),
    );
  }
}
