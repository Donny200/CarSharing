import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';

class RentalOptionSheet extends StatefulWidget {
  final String carName;
  final int pricePerMinute;
  final int pricePerDay;
  final VoidCallback onStartRental;

  const RentalOptionSheet({
    super.key,
    required this.carName,
    required this.pricePerMinute,
    required this.pricePerDay,
    required this.onStartRental,
  });

  @override
  _RentalOptionSheetState createState() => _RentalOptionSheetState();
}

class _RentalOptionSheetState extends State<RentalOptionSheet> {
  String? selectedTariff;

  @override
  Widget build(BuildContext context) {
    final loc = Provider.of<LocalizationService>(context);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.grey[100]!],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.carName, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          RadioListTile<String>(
            title: Text(loc.tr('minute_price', {'price': widget.pricePerMinute.toString()}), style: theme.textTheme.bodyLarge),
            value: 'minute',
            groupValue: selectedTariff,
            onChanged: (value) => setState(() => selectedTariff = value),
            activeColor: Colors.teal,
          ),
          RadioListTile<String>(
            title: Text(loc.tr('day_price', {'price': widget.pricePerDay.toString()}), style: theme.textTheme.bodyLarge),
            value: 'day',
            groupValue: selectedTariff,
            onChanged: (value) => setState(() => selectedTariff = value),
            activeColor: Colors.teal,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: selectedTariff != null ? widget.onStartRental : null,
              icon: const Icon(Icons.play_arrow),
              label: Text(loc.tr('start'), style: const TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 10,
                shadowColor: Colors.green.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}