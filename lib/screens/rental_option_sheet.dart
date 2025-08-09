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
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.carName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          RadioListTile<String>(
            title: Text(loc.tr('minute_price', {'price': widget.pricePerMinute.toString()})),
            value: 'minute',
            groupValue: selectedTariff,
            onChanged: (value) => setState(() => selectedTariff = value),
          ),
          RadioListTile<String>(
            title: Text(loc.tr('day_price', {'price': widget.pricePerDay.toString()})),
            value: 'day',
            groupValue: selectedTariff,
            onChanged: (value) => setState(() => selectedTariff = value),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: selectedTariff != null ? widget.onStartRental : null,
            icon: const Icon(Icons.play_arrow),
            label: Text(loc.tr('start')),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      ),
    );
  }
}
