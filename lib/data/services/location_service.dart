import 'package:geolocator/geolocator.dart';

enum LocationAccessStatus {
  granted,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
}

class LocationService {
  int _denialCount = 0;
  static const int maxDenialAttempts = 3;

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<bool> openLocationSettings() {
    return Geolocator.openLocationSettings();
  }

  Future<LocationAccessStatus> checkPermission() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationAccessStatus.serviceDisabled;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      if (_denialCount >= maxDenialAttempts) {
        return LocationAccessStatus.permissionDeniedForever;
      }
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _denialCount++;
        return _denialCount >= maxDenialAttempts
            ? LocationAccessStatus.permissionDeniedForever
            : LocationAccessStatus.permissionDenied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationAccessStatus.permissionDeniedForever;
    }

    _denialCount = 0;
    return LocationAccessStatus.granted;
  }



  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  Future<Position> getCurrentLocation() {
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception(
        'Could not get location — check GPS/emulator location settings',
      ),
    );
  }

  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    );
  }
}