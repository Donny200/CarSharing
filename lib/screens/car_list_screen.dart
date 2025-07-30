import 'package:flutter/material.dart';

class CarListScreen extends StatelessWidget {
  const CarListScreen({super.key});

  final List<String> cars = const [
    'Chevrolet Cobalt',
    'Damas 2023',
    'Malibu Turbo',
    'Spark',
    'Tracker LTZ',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Список машин')),
      body: ListView.builder(
        itemCount: cars.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(cars[index]),
              leading: const Icon(Icons.directions_car),
              trailing: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${cars[index]} забронирована')),
                  );
                },
                child: const Text('Забронировать'),
              ),
            ),
          );
        },
      ),
    );
  }
}
