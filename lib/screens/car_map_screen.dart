import 'dart:async';
import 'dart:convert';
import 'package:carsharing/screens/payment_history_screen.dart';
import 'package:carsharing/screens/payment_screen.dart';
import 'package:carsharing/screens/settings_screen.dart';
import 'package:carsharing/services/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/localization_service.dart';
import '../widgets/language_button.dart';
import 'rental_option_sheet.dart';
import 'user_profile_screen.dart';

class CarMapScreen extends StatefulWidget {
  const CarMapScreen({super.key});

  @override
  State<CarMapScreen> createState() => _CarMapScreenState();
}

class _CarMapScreenState extends State<CarMapScreen> {
  Map<String, dynamic>? _currentCar;
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  List<LatLng> _route = [];

  bool _isRenting = false;
  Timer? _rentalTimer;
  int _rentalSeconds = 0;

  final List<Map<String, dynamic>> _cars = [
    {
      'name': 'Chevrolet Cobalt',
      'location': LatLng(41.302, 69.241),
      'pricePerMinute': 120,
      'pricePerDay': 70000,
    },
    {
      'name': 'Malibu Turbo',
      'location': LatLng(41.305, 69.244),
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
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    setState(() => _currentLocation = LatLng(position.latitude, position.longitude));
  }

  Future<void> _fetchRoute(LatLng carLoc) async {
    if (_currentLocation == null) return;

    final start = '${_currentLocation!.longitude},${_currentLocation!.latitude}';
    final end = '${carLoc.longitude},${carLoc.latitude}';
    final url = Uri.parse('https://router.project-osrm.org/route/v1/driving/$start;$end?overview=full&geometries=geojson');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final coordinates = data['routes'][0]['geometry']['coordinates'] as List;
      final points = coordinates.map((p) => LatLng(p[1], p[0])).toList();
      setState(() => _route = points);
    }
  }

  void _showCarActions(Map<String, dynamic> car) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
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
              child: Consumer<LocalizationService>(builder: (c, loc, _) => Text(loc.tr('show_route'))),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showRentalSheet(car);
              },
              child: Consumer<LocalizationService>(builder: (c, loc, _) => Text(loc.tr('rent'))),
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
        onStartRental: () {
          _currentCar = car;
          _startRental();
        },
      ),
    );
  }

  void _startRental() {
    setState(() {
      _isRenting = true;
      _rentalSeconds = 0;
    });

    _rentalTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      // списание каждую минуту
      if (_rentalSeconds % 60 == 0 && _currentCar != null && _rentalSeconds != 0) {
        await UserDataService.deductFromBalance(_currentCar!['pricePerMinute']);
      }
      setState(() {
        _rentalSeconds += 1;
      });
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
    final loc = Provider.of<LocalizationService>(context);
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            FutureBuilder<int>(
              future: UserDataService.getBalance(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const DrawerHeader(
                    decoration: BoxDecoration(color: Colors.blueGrey),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return DrawerHeader(
                  decoration: const BoxDecoration(color: Colors.blueGrey),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc.tr('profile'), style: const TextStyle(color: Colors.white, fontSize: 24)),
                      const SizedBox(height: 10),
                      Text('${loc.tr('amount')}: ${snapshot.data} сум', style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(loc.tr('profile')),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfileScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(loc.tr('settings')),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: Text(loc.tr('payment')),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: Text(loc.tr('payment_history')),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentHistoryScreen()));
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(loc.tr('cars_map')),
        actions: const [LanguageButton()],
      ),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(center: _currentLocation, zoom: 15.0),
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
                  if (_currentLocation != null)
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
                    loc.tr('rent_time', {
                      'min': ((_rentalSeconds) ~/ 60).toString(),
                      'sec': ((_rentalSeconds) % 60).toString()
                    }),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _stopRental,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text(loc.tr('end_rental')),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentLocation != null) {
            _mapController.move(_currentLocation!, 15.0);
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
