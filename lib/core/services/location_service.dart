import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:project/core/utils/result.dart';

class LocationService {
  Future<Result<Position>> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Result.error('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Result.error('Location permission permanently denied');
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return Result.success(position);
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  Result<double> getDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    final distanceInMeters = Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
    return Result.success(distanceInMeters / 1000);
  }

  Future<Result<String>> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
        ].where((s) => s != null && s.isNotEmpty).toList();
        final name = parts.take(3).join(', ');
        return Result.success(name);
      }
      return Result.error('Unknown Location');
    } catch (e) {
      return Result.error(e.toString());
    }
  }
}
