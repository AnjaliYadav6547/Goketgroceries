import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialPosition;
  final Function(String) onLocationSelected;
  
  const LocationPickerScreen({
    super.key,
    this.initialPosition,
    required this.onLocationSelected,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late GoogleMapController _mapController;
  LatLng? _selectedPosition;
  String _address = "Locating...";
  bool _isLoading = true;

@override
  void initState() {
    super.initState();
    if (widget.initialPosition != null) {
      _selectedPosition = widget.initialPosition;
      _loadAddress(widget.initialPosition!);
      _isLoading = false;
    } else {
      _initCurrentLocation();
    }
  }

  Future<void> _loadAddress(LatLng position) async {
    final address = await LocationService.latLngToAddress(position);
    if (mounted) {
      setState(() => _address = address ?? "Address unavailable");
    }
  }


  Future<void> _initCurrentLocation() async {
    final position = await LocationService.getCurrentLatLng();
    if (position != null) {
      final address = await LocationService.latLngToAddress(position);
      setState(() {
        _selectedPosition = position;
        _address = address ?? "Address unavailable";
        _isLoading = false;
      });
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(position, 15),
      );
    } else {
      setState(() {
        _isLoading = false;
        _address = "Could not determine location";
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTapped(LatLng position) async {
    final address = await LocationService.latLngToAddress(position);
    setState(() {
      _selectedPosition = position;
      _address = address ?? "Address unavailable";
    });
  }

  static Future<List<Location>> addressToCoordinates(String address) async {
  try {
    return await locationFromAddress(address);
  } catch (e) {
    print('Error converting address: $e');
    return [];
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _initCurrentLocation,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _selectedPosition ?? const LatLng(0, 0),
                      zoom: 15,
                    ),
                    markers: _selectedPosition != null
                        ? {
                            Marker(
                              markerId: const MarkerId('selected'),
                              position: _selectedPosition!,
                              draggable: true,
                              onDragEnd: _onMapTapped,
                            ),
                          }
                        : {},
                    onTap: _onMapTapped,
                    myLocationEnabled: true,
                  ),
                ),
                _buildLocationCard(),
              ],
            ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Selected Location:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(_address),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: _selectedPosition != null
                  ? () {
                      widget.onLocationSelected(_address);
                      Navigator.pop(context);
                    }
                  : null,
              child: const Text('Confirm Location'),
            ),
          ],
        ),
      ),
    );
  }
}