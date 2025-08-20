import 'dart:async';
import 'dart:convert';
import 'package:carsharing/screens/payment_history_screen.dart';
import 'package:carsharing/screens/payment_screen.dart';
import 'package:carsharing/screens/settings_screen.dart';
import 'package:carsharing/services/auth_start_screen.dart';
import 'package:carsharing/services/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/localization_service.dart';
import '../widgets/language_button.dart';
import 'rental_option_sheet.dart';
import 'user_profile_screen.dart';
import 'trip_history_screen.dart';

class CarMapScreen extends StatefulWidget {
  const CarMapScreen({super.key});

  @override
  State<CarMapScreen> createState() => _CarMapScreenState();
}

class _CarMapScreenState extends State<CarMapScreen> {

  final MapController _mapController = MapController();

  LatLng? _userLocation;
  List<Map<String, dynamic>> _cars = [];
  List<LatLng> _route = [];

  bool _isRenting = false;
  Timer? _rentalTimer;
  int _rentalSeconds = 0;

  bool _loadingCars = false;
  bool _loadingBalance = false;

  double? _walletBalance;
  String? _walletCurrency;
  DateTime? _walletLastUpdated;


  static const String carsUrl = 'https://ddede65e4d59.ngrok-free.app/admin/get-all-cars';
  static const String walletUrl = 'https://hockey-jill-shoulder-psp.trycloudflare.com/wallet/my-wallet';

  final _secureStorage = const FlutterSecureStorage();


  @override
  void initState() {
    super.initState();

    _secureStorage.read(key: 'accessToken').then((token) async {
      if (token == null) {
        debugPrint('Нет токена — на экран авторизации');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthStartScreen()));
      } else {
        await _determinePosition();
        await _fetchWallet();
      }
    });
  }

  @override
  void dispose() {
    _rentalTimer?.cancel();
    super.dispose();
  }


  Future<void> _fetchWallet() async {
    setState(() => _loadingBalance = true);
    try {
      final token = await _secureStorage.read(key: 'accessToken');
      if (token == null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthStartScreen()));
        return;
      }

      final res = await http.get(
        Uri.parse(walletUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 12));

      debugPrint('Wallet status: ${res.statusCode}');
      debugPrint('Wallet body: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map<String, dynamic>) {
          final bal = data['balance'];
          final cur = data['currency'];
          final upd = data['lastUpdated'];
          setState(() {
            _walletBalance = (bal is num) ? bal.toDouble() : (bal is String ? double.tryParse(bal) : null);
            _walletCurrency = cur?.toString();
            _walletLastUpdated = upd != null ? DateTime.tryParse(upd.toString()) : null;
          });
        }
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Сессия истекла. Пожалуйста, войдите снова.')),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthStartScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка кошелька: ${res.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint('Ошибка запроса кошелька: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось получить баланс кошелька')),
      );
    } finally {
      setState(() => _loadingBalance = false);
    }
  }


  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Службы геолокации отключены. Пожалуйста, включите их.'),
            action: SnackBarAction(
              label: 'Включить',
              onPressed: () async {
                await Geolocator.openLocationSettings();
                serviceEnabled = await Geolocator.isLocationServiceEnabled();
                if (serviceEnabled) _determinePosition();
              },
            ),
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Разрешение на геолокацию отклонено'),
              action: SnackBarAction(
                label: 'Попробовать снова',
                onPressed: () => _determinePosition(),
              ),
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Разрешение на геолокацию отклонено навсегда. Включите в настройках.'),
            action: SnackBarAction(
              label: 'Открыть настройки',
              onPressed: () async {
                await Geolocator.openAppSettings();
                permission = await Geolocator.checkPermission();
                if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
                  _determinePosition();
                }
              },
            ),
          ),
        );
        return;
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _userLocation = LatLng(pos.latitude, pos.longitude);
        });
        _mapController.move(_userLocation!, 15.0);
        await _loadCars();
      }
    } catch (e) {
      // debugPrint('Ошибка определения локации: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось определить местоположение')),
      );
    }
  }


  Future<void> _loadCars() async {
    if (_loadingCars) return;
    setState(() => _loadingCars = true);

    try {
      final String? token = await _secureStorage.read(key: 'accessToken');
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка: Токен авторизации не найден')),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthStartScreen()));
        return;
      }

      final res = await http
          .get(
        Uri.parse(carsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      )
          .timeout(const Duration(seconds: 12));

      debugPrint('Cars status: ${res.statusCode}');
      if (res.statusCode == 200) {
        final jsonBody = jsonDecode(res.body);
        List<dynamic> list;
        if (jsonBody is Map && jsonBody['cars'] is List) {
          list = jsonBody['cars'] as List<dynamic>;
        } else if (jsonBody is List) {
          list = jsonBody;
        } else {
          list = const [];
        }

        final parsed = <Map<String, dynamic>>[];
        for (final item in list) {
          final car = _parseCarJson(item);
          if (car != null) parsed.add(car);
        }

        setState(() {
          _cars = parsed;
          if (_cars.isNotEmpty) {
            _mapController.move(LatLng(_cars[0]['lat'], _cars[0]['lng']), 15.0);
          }
        });
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка авторизации. Пожалуйста, войдите снова.')),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthStartScreen()));
      } else {
        final bodyPreview = res.body.length > 200 ? '${res.body.substring(0, 200)}...' : res.body;
        debugPrint('Ошибка загрузки машин: ${res.statusCode} $bodyPreview');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось загрузить машины (${res.statusCode})')),
        );
      }
    } catch (e) {
      debugPrint('Ошибка при запросе машин: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось загрузить машины')),
      );
    } finally {
      setState(() => _loadingCars = false);
    }
  }

  Map<String, dynamic>? _parseCarJson(dynamic item) {
    try {
      if (item == null || item is! Map) return null;

      double? lat;
      double? lng;

      if (item['latitude'] != null && item['longitude'] != null) {
        lat = _toDouble(item['latitude']);
        lng = _toDouble(item['longitude']);
      } else if (item['lat'] != null && item['lng'] != null) {
        lat = _toDouble(item['lat']);
        lng = _toDouble(item['lng']);
      } else if (item['location'] != null) {
        final loc = item['location'];
        if (loc is Map) {
          if (loc['lat'] != null && loc['lng'] != null) {
            lat = _toDouble(loc['lat']);
            lng = _toDouble(loc['lng']);
          } else if (loc['latitude'] != null && loc['longitude'] != null) {
            lat = _toDouble(loc['latitude']);
            lng = _toDouble(loc['longitude']);
          } else if (loc['coordinates'] != null && loc['coordinates'] is List) {
            final coords = List.from(loc['coordinates']);
            if (coords.length >= 2) {
              lng = _toDouble(coords[0]);
              lat = _toDouble(coords[1]);
            }
          }
        } else if (loc is List && loc.length >= 2) {
          lng = _toDouble(loc[0]);
          lat = _toDouble(loc[1]);
        }
      } else if (item['coordinates'] != null && item['coordinates'] is List) {
        final coords = List.from(item['coordinates']);
        if (coords.length >= 2) {
          lng = _toDouble(coords[0]);
          lat = _toDouble(coords[1]);
        }
      }

      if (lat == null || lng == null) {
        debugPrint('Не удалось распарсить координаты авто: $item');
        return null;
      }

      String name = '';
      if (item['name'] != null) {
        name = item['name'].toString();
      } else if (item['title'] != null) {
        name = item['title'].toString();
      } else if (item['make'] != null && item['model'] != null) {
        name = '${item['make']} ${item['model']}';
      } else {
        name = 'Car ${item['id'] ?? ''}';
      }

      final dynamic price = item['price'] ??
          item['pricePerMinute'] ??
          item['rentalPrice'] ??
          item['dailyPrice'] ??
          item['cost'];

      return {
        'id': item['id'],
        'name': name,
        'lat': lat,
        'lng': lng,
        'raw': item,
        'price': price,
      };
    } catch (e) {
      debugPrint('Parse car error: $e for item: $item');
      return null;
    }
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v * 1.0;
    if (v is String) return double.tryParse(v);
    return null;
  }


  double _distanceMeters(LatLng a, LatLng b) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Meter, a, b);
  }

  Future<void> _fetchRoute(LatLng carLoc) async {
    if (_userLocation == null) return;

    final start = '${_userLocation!.longitude},${_userLocation!.latitude}';
    final end = '${carLoc.longitude},${carLoc.latitude}';
    final url = Uri.parse('https://router.project-osrm.org/route/v1/driving/$start;$end?overview=full&geometries=geojson');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coords = data['routes'][0]['geometry']['coordinates'] as List;
        final points = coords
            .map<LatLng>((p) => LatLng((p[1] as num).toDouble(), (p[0] as num).toDouble()))
            .toList();
        setState(() => _route = points);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка маршрута: ${response.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint('Ошибка маршрута: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось построить маршрут')),
      );
    }
  }

  void _showCarDetails(Map<String, dynamic> car) {
    if (_userLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Не удалось определить местоположение')));
      return;
    }

    final carPos = LatLng(car['lat'], car['lng']);
    final dist = _distanceMeters(_userLocation!, carPos);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final theme = Theme.of(context);
        final priceText = car['price'] != null ? car['price'].toString() : '—';
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(car['name'] ?? 'Машина', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('Цена: $priceText', style: theme.textTheme.bodyLarge),
              const SizedBox(height: 8),
              Text('Расстояние: ${dist.toStringAsFixed(0)} м', style: theme.textTheme.bodyLarge),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.map),
                    label: const Text('Показать маршрут'),
                    onPressed: () {
                      Navigator.pop(context);
                      _fetchRoute(carPos);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.drive_eta),
                    label: const Text('Арендовать'),
                    onPressed: () {
                      Navigator.pop(context);
                      _showRentalSheet(car);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.teal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNearestCarsSheet() {
    if (_userLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Не удалось определить местоположение')));
      return;
    }

    if (_loadingCars) {
      showModalBottomSheet(
        context: context,
        builder: (_) => const SizedBox(
          height: 400,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
      return;
    }

    if (_cars.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Машины не найдены')));
      return;
    }

    final list = List<Map<String, dynamic>>.from(_cars);
    list.sort((a, b) {
      final da = _distanceMeters(_userLocation!, LatLng(a['lat'], a['lng']));
      final db = _distanceMeters(_userLocation!, LatLng(b['lat'], b['lng']));
      return da.compareTo(db);
    });

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SizedBox(
        height: 420,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Машины рядом (${list.length})', style: Theme.of(context).textTheme.headlineSmall),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final car = list[i];
                  final d = _distanceMeters(_userLocation!, LatLng(car['lat'], car['lng']));
                  final price = car['price'];
                  final priceStr = (price == null) ? '—' : price.toString();
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.directions_car, color: Colors.teal),
                      title: Text(car['name'] ?? 'Неизвестная машина', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${d.toStringAsFixed(0)} м — Цена: $priceStr'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pop(context);
                        _mapController.move(LatLng(car['lat'], car['lng']), 17.0);
                        Future.delayed(const Duration(milliseconds: 250), () => _showCarDetails(car));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRentalSheet(Map<String, dynamic> car) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RentalOptionSheet(
        carName: car['name'] ?? '',
        pricePerMinute: (car['price'] is num) ? (car['price'] as num).toInt() : 0,
        pricePerDay: 0,
        onStartRental: () {
          _startBooking(car);
        },
      ),
    );
  }


  Future<void> _startBooking(Map<String, dynamic> car) async {
    try {
      final token = await _secureStorage.read(key: 'accessToken');
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка: нет токена авторизации')),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthStartScreen()));
        return;
      }

      final url = Uri.parse('https://hockey-jill-shoulder-psp.trycloudflare.com/book/start?carId=5');
      final res = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        _startRentalForCar(car);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка старта аренды: ${res.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint('Ошибка старта аренды: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось начать аренду')),
      );
    }
  }

  void _startRentalForCar(Map<String, dynamic> car) {
    setState(() {
      _isRenting = true;
      _rentalSeconds = 0;
    });

    _rentalTimer?.cancel();
    _rentalTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      // Каждую минуту — списываем цену (если она указана)
      if (_rentalSeconds % 60 == 0 && _rentalSeconds != 0) {
        final price = car['price'];
        if (price is num) {
          // локальное списание (если у тебя бэк сам списывает — убери)
          await UserDataService.deductFromBalance(price.toInt());
          // и обновим баланс из кошелька
          _fetchWallet();
        }
      }
      setState(() => _rentalSeconds += 1);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Начата аренда: ${car['name']}')),
    );
  }

  void _stopRental() {
    _rentalTimer?.cancel();
    setState(() {
      _isRenting = false;
      _rentalSeconds = 0;
      _route.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Аренда завершена')),
    );
  }


  @override
  Widget build(BuildContext context) {
    final loc = Provider.of<LocalizationService>(context);
    final theme = Theme.of(context);
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: theme.primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.tr('profile'), style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white)),
                  const SizedBox(height: 16),
                  if (_loadingBalance)
                    const SizedBox(height: 28, width: 28, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  else
                    Text(
                      _formatWalletBalance(loc),
                      style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                    ),
                  if (_walletLastUpdated != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Обновлено: ${_walletLastUpdated!.toLocal()}',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ],
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.teal),
              title: Text(loc.tr('profile')),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfileScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.teal),
              title: Text(loc.tr('settings')),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.teal),
              title: const Text('История поездок'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TripHistoryScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.payment, color: Colors.teal),
              title: Text(loc.tr('payment')),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.teal),
              title: Text(loc.tr('payment_history')),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentHistoryScreen())),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(loc.tr('cars_map'), style: theme.textTheme.headlineMedium),
        backgroundColor: theme.primaryColor,
        actions: const [LanguageButton()],
        elevation: 0,
      ),
      body: _userLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _userLocation,
              zoom: 15.0,
              onTap: (_, __) {
                setState(() {
                  _route.clear();
                });
              },
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
                  if (_userLocation != null)
                    Marker(
                      point: _userLocation!,
                      width: 48,
                      height: 48,
                      child: const Icon(Icons.my_location, color: Colors.blue, size: 36),
                    ),
                  ..._cars.map((car) {
                    final carPos = LatLng(car['lat'], car['lng']);
                    return Marker(
                      point: carPos,
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => _showCarDetails(car),
                        child: const Icon(Icons.directions_car, color: Colors.red, size: 36),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ],
          ),

          if (_isRenting)
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        loc.tr('rent_time', {
                          'min': ((_rentalSeconds) ~/ 60).toString(),
                          'sec': ((_rentalSeconds) % 60).toString()
                        }),
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.stop),
                          label: Text(loc.tr('end_rental')),
                          onPressed: _stopRental,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'loc',
            onPressed: () {
              if (_userLocation != null) {
                _mapController.move(_userLocation!, 15.0);
              }
            },
            backgroundColor: Colors.teal,
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'cars',
            onPressed: () async {
              await _loadCars();
              _showNearestCarsSheet();
            },
            backgroundColor: Colors.teal,
            icon: _loadingCars
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
                : const Icon(Icons.directions_car),
            label: const Text('Рядом'),
          ),
        ],
      ),
    );
  }


  String _formatWalletBalance(LocalizationService loc) {
    if (_walletBalance == null) return '${loc.tr('amount')}: —';
    final cur = _walletCurrency ?? 'UZS';
    final intPart = _walletBalance!.floor();
    final str = _formatThousands(intPart);
    return '${loc.tr('amount')}: $str $cur';
  }

  String _formatThousands(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buf.write(s[i]);
      count++;
      if (count == 3 && i != 0) {
        buf.write(' ');
        count = 0;
      }
    }
    return buf.toString().split('').reversed.join();
  }
}