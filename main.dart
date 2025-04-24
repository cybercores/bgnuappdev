import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(const MyMapApp());

class MyMapApp extends StatelessWidget {
  const MyMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'House Map',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MapScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filterOptions = ['House', 'Park', 'School', 'Hospital'];
  String _selectedFilter = 'House';
  LatLng _houseLocation = const LatLng(40.7128, -74.0060);
  bool _isSearching = false;
  double _currentZoom = 15.0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    setState(() => _houseLocation = LatLng(position.latitude, position.longitude));
    _mapController.move(_houseLocation, _currentZoom);
  }

  void _searchLocations() {
    setState(() => _isSearching = true);

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isSearching = false;
        double offset = switch (_selectedFilter) {
          'Park' => 0.02,
          'School' => 0.03,
          'Hospital' => -0.02,
          _ => 0.01,
        };

        _mapController.move(
          LatLng(_houseLocation.latitude + offset, _houseLocation.longitude + offset),
          _currentZoom,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My House Map')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _houseLocation,
              zoom: _currentZoom,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) setState(() => _currentZoom = position.zoom ?? _currentZoom);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.house_map_app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _houseLocation,
                    width: 80,
                    height: 80,
                    builder: (ctx) => const Icon(Icons.home, color: Colors.red, size: 40),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search near my house...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _isSearching = false);
                          },
                        ),
                      ),
                      onSubmitted: (_) => _searchLocations(),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedFilter,
                      items: _filterOptions.map((value) =>
                          DropdownMenuItem(value: value, child: Text(value))
                      ).toList(),
                      onChanged: (newValue) =>
                          setState(() => _selectedFilter = newValue!),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isSearching) const Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}