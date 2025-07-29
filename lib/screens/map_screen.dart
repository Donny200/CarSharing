import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'rental_screen.dart';
import 'profile_screen.dart';
import 'dart:async';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _currentLocation;
  String? _distanceToNearest;
  List<LatLng> _route = [];
  final MapController _mapController = MapController();

  final List<Map<String, dynamic>> _carList = [
    {
      'name': 'Toyota Camry',
      'location': LatLng(41.3111, 69.2797),
      'pricePerMinute': 1000,
      'pricePerDay': 200000,
    },
    {
      'name': 'Malibu Turbo',
      'location': LatLng(41.3150, 69.2845),
      'pricePerMinute': 1200,
      'pricePerDay': 220000,
    },
    {
      'name': 'Kia Optima',
      'location': LatLng(41.3090, 69.2810),
      'pricePerMinute': 900,
      'pricePerDay': 180000,
    },
  ];

  StreamSubscription<Position>? _positionSub;

  @override
  void initState() {
    super.initState();
    _listenUserMovement();
  }

  void _listenUserMovement() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionSub = Geolocator.getPositionStream(locationSettings: locationSettings).listen((pos) {
      final newLoc = LatLng(pos.latitude, pos.longitude);
      setState(() => _currentLocation = newLoc);
      _calculateNearestDistance(newLoc);
    });

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return;

    Position pos = await Geolocator.getCurrentPosition();
    _currentLocation = LatLng(pos.latitude, pos.longitude);
    _calculateNearestDistance(_currentLocation!);
    _mapController.move(_currentLocation!, 15);
    setState(() {});
  }

  void _calculateNearestDistance(LatLng userLoc) {
    double minDist = double.infinity;
    for (var car in _carList) {
      final c = car['location'] as LatLng;
      double d = Geolocator.distanceBetween(
          userLoc.latitude, userLoc.longitude, c.latitude, c.longitude);
      if (d < minDist) {
        minDist = d;
      }
    }
    setState(() {
      _distanceToNearest = minDist > 1000
          ? 'Ближайшая машина: ${(minDist / 1000).toStringAsFixed(2)} км'
          : 'Ближайшая машина: ${minDist.toStringAsFixed(0)} м';
    });
  }

  void _centerOnUser() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15);
    }
  }

  void _showRouteTo(Map<String, dynamic> car) {
    final LatLng carLoc = car['location'];
    if (_currentLocation == null) return;
    setState(() {
      _route = [_currentLocation!, carLoc];
    });
    _mapController.fitBounds(
      LatLngBounds(_currentLocation!, carLoc),
      options: const FitBoundsOptions(padding: EdgeInsets.all(50)),
    );

    showModalBottomSheet(
      context: context,
      builder: (_) => RentalScreen(
        carName: car['name'],
        pricePerMinute: car['pricePerMinute'],
        pricePerDay: car['pricePerDay'],
      ),
    );
  }

  @override
  void dispose() {
    _positionSub?.cancel();
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
      body: Column(
        children: [
          if (_distanceToNearest != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _distanceToNearest!,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: _currentLocation ?? LatLng(41.3111, 69.2797),
                    zoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: 'com.example.carsharing',
                    ),
                    if (_route.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _route,
                            color: Colors.green,
                            strokeWidth: 5,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        if (_currentLocation != null)
                          Marker(
                            point: _currentLocation!,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.my_location, color: Colors.blue),
                          ),
                        ..._carList.map((car) {
                          return Marker(
                            point: car['location'],
                            width: 50,
                            height: 50,
                            child: GestureDetector(
                              onTap: () => _showRouteTo(car),
                              child: const Icon(Icons.directions_car, color: Colors.red, size: 30),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    heroTag: "center_user",
                    onPressed: _centerOnUser,
                    child: const Icon(Icons.gps_fixed),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}