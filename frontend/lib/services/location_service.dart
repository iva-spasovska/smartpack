import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<String> currentDestinationLabel() async {
    final position = await _currentPosition();
    final places = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (places.isEmpty) {
      return '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
    }

    final place = places.first;
    final parts = [
      place.locality,
      place.administrativeArea,
      place.country,
    ].where((part) => part != null && part.trim().isNotEmpty).cast<String>();

    return parts.join(', ');
  }

  Future<Position> _currentPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw Exception('Location services are disabled');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }
}
