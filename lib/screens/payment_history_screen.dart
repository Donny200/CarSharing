import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_data.dart';
import '../services/localization_service.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = Provider.of<LocalizationService>(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.tr('payment_history')), actions: const [SizedBox(width: 8)]),
      body: FutureBuilder<List<String>>(
        future: UserDataService.getPaymentHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.isEmpty) return Center(child: Text(loc.tr('empty_history')));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: snapshot.data!.map((e) => Card(child: ListTile(title: Text(e)))).toList(),
          );
        },
      ),
    );
  }
}
