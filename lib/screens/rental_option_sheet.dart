import 'package:flutter/material.dart';

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
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.carName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          RadioListTile<String>(
            title: Text('₸ ${widget.pricePerMinute} / минута'),
            value: 'minute',
            groupValue: selectedTariff,
            onChanged: (value) => setState(() => selectedTariff = value),
          ),
          RadioListTile<String>(
            title: Text('₸ ${widget.pricePerDay} / сутки'),
            value: 'day',
            groupValue: selectedTariff,
            onChanged: (value) => setState(() => selectedTariff = value),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: selectedTariff != null ? widget.onStartRental : null,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Старт'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      ),
    );
  }
}
