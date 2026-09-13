import 'package:flutter_rider_tracking_app/data/services/location_service.dart';
import 'package:flutter_rider_tracking_app/data/services/trip_database.dart';
import 'package:flutter_rider_tracking_app/model/location_model.dart';
import 'package:flutter_rider_tracking_app/model/trip_tracking_model.dart';

class TrackingRepository {
  final TripDatabase database;
  final LocationService locationService;

  TrackingRepository({
    required this.database,
    required this.locationService,
  });

  Future<int> startTrip({
    required double startLatitude,
    required double startLongitude,
}) async {
    final trip = TripTrackingModel(
      status: 'running',
      startTime: DateTime.now(),
      totalDistance: 0.0,
      currentSpeed: 0.0,
      maxSpeed: 0.0,
      startLatitude: startLatitude,
      startLongitude: startLongitude,
    );

    return database.createTrip(trip);
  }

  Future<void> saveLocation(
      LocationModel location,
      ) async {
    await database.insertLocation(location);
  }

  Future<void> updateTripData({
    required int tripId,
    required double distance,
    required double currentSpeed,
    required double maxSpeed,
    required double latitude,
    required double longitude,
  }) async {
    await database.updateTripData(
      tripId: tripId,
      distance: distance,
      currentSpeed: currentSpeed,
      maxSpeed: maxSpeed,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<void> updateTrip(
      TripTrackingModel trip,
      ) async {
    await database.updateTrip(trip);
  }

  Future<TripTrackingModel?> getActiveTrip() async {
    return database.getActiveTrip();
  }
}