import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static Future<String?> getCurrentAddress() async {
    try {
      // Step 1: Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are disabled - prompt user to enable them
        bool enabled = await Geolocator.openLocationSettings();
        if (!enabled) {
          return 'Location services disabled';
        }
      }

      // Step 2: Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'Location permissions denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions permanently denied - direct user to app settings
        bool opened = await Geolocator.openAppSettings();
        if (!opened) {
          return 'Location permissions permanently denied';
        }
        return null;
      }

      // Step 3: Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Step 4: Convert coordinates to address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.postalCode,
          place.country
        ].where((part) => part?.isNotEmpty ?? false).join(', ');
      }
      return null;
    } catch (e) {
      print('Location error: $e');
      return null;
    }
  }
  

  /// Get current position as LatLng (for maps)
  static Future<LatLng?> getCurrentLatLng() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting LatLng: $e');
      return null;
    }
  }

  /// Convert address to coordinates (reverse geocoding)
  static Future<LatLng?> addressToLatLng(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
      return null;
    } catch (e) {
      print('Error converting address: $e');
      return null;
    }
  }

  /// Get address from LatLng (when user taps on map)
  static Future<String?> latLngToAddress(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return [
          place.street,
          place.locality,
          place.administrativeArea,
          place.country
        ].where((p) => p?.isNotEmpty ?? false).join(', ');
      }
      return null;
    } catch (e) {
      print('Error converting LatLng: $e');
      return null;
    }
  }
}