import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'rental_option_sheet.dart';
import 'profile_screen.dart';

//email, gender, phoneNumber, app"HAYDA", password, lastName, firstName

class CarMapScreen extends StatefulWidget {
  const CarMapScreen({super.key});

  @override
  State<CarMapScreen> createState() => _CarMapScreenState();
}

class _CarMapScreenState extends State<CarMapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  List<LatLng> _route = [];

  bool _isRenting = false;
  Timer? _rentalTimer;
  int _rentalSeconds = 0;

  final List<Map<String, dynamic>> _cars = [
    {
      'name': 'Chevrolet Cobalt',
      'location': const LatLng(41.302, 69.241),
      'pricePerMinute': 120,
      'pricePerDay': 70000,
    },
    {
      'name': 'Malibu Turbo',
      'location': const LatLng(41.305, 69.244),
      'pricePerMinute': 150,
      'pricePerDay': 90000,
    },
  ];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    final perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return;
    final pos = await Geolocator.getCurrentPosition();
    setState(() => _currentLocation = LatLng(pos.latitude, pos.longitude));
  }

  Future<void> _fetchRoute(LatLng carLoc) async {
    if (_currentLocation == null) return;
    final start = '${_currentLocation!.longitude},${_currentLocation!.latitude}';
    final end = '${carLoc.longitude},${carLoc.latitude}';
    final url = Uri.parse('https://router.project-osrm.org/route/v1/driving/$start;$end?overview=full&geometries=geojson');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      final coords = data['routes'][0]['geometry']['coordinates'] as List;
      final points = coords.map((p) => LatLng(p[1], p[0])).toList();
      setState(() => _route = points);
    }
  }

  void _showCarActions(Map<String, dynamic> car) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Выберите действие для ${car['name']}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _fetchRoute(car['location']);
              },
              child: const Text('Показать маршрут'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showRentalSheet(car);
              },
              child: const Text('Арендовать'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRentalSheet(Map<String, dynamic> car) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (_) => RentalOptionSheet(
        carName: car['name'],
        pricePerMinute: car['pricePerMinute'],
        pricePerDay: car['pricePerDay'],
        onStartRental: _startRental,
      ),
    );
  }

  void _startRental() {
    setState(() {
      _isRenting = true;
      _rentalSeconds = 0;
    });
    _rentalTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _rentalSeconds++);
    });
    Navigator.of(context).pop();
  }

  void _stopRental() {
    _rentalTimer?.cancel();
    setState(() {
      _isRenting = false;
      _rentalSeconds = 0;
      _route.clear();
    });
  }

  @override
  void dispose() {
    _rentalTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карта машин'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _currentLocation,
              zoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.carsharing',
              ),
              if (_route.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(points: _route, color: Colors.green, strokeWidth: 5),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLocation!,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                  ),
                  ..._cars.map((car) => Marker(
                    point: car['location'],
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showCarActions(car),
                      child: const Icon(Icons.directions_car, color: Colors.red, size: 36),
                    ),
                  )),
                ],
              ),
            ],
          ),
          if (_isRenting)
            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Text(
                    'Время аренды: ${_rentalSeconds ~/ 60} мин ${_rentalSeconds % 60} сек',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _stopRental,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Завершить аренду'),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentLocation != null) _mapController.move(_currentLocation!, 15.0);
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
