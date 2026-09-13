import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/repository/tracking_repository.dart';
import '../../data/services/location_service.dart';
import '../../model/location_model.dart';
import '../../model/trip_tracking_model.dart';
import 'tracking_event.dart';
import 'tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final TrackingRepository repository;

  Timer? _locationTimer;
  LatLng? _lastLocation;
  int? _currentTripId;
  double _totalDistance = 0.0;
  double _maxSpeed = 0.0;
  List<LatLng> _routePoints = [];

  TrackingBloc({required this.repository}) : super(const TrackingState()) {
    on<StartTrip>(_onStartTrip);
    on<EndTrip>(_onEndTrip);
  }

  // Calculate distance between two points in km
  double _calculateDistance(LatLng start, LatLng end) {
    const earthRadius = 6371;
    final dLat = _degreesToRadians(end.latitude - start.latitude);
    final dLng = _degreesToRadians(end.longitude - start.longitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(start.latitude)) *
            cos(_degreesToRadians(end.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180;

  Future<void> _onStartTrip(
      StartTrip event,
      Emitter<TrackingState> emit,
      ) async {
    try {
      emit(state.copyWith(status: TripStatus.initial));

      final locationStatus = await repository.locationService.checkPermission();

      if (locationStatus == LocationAccessStatus.serviceDisabled) {
        emit(state.copyWith(
          status: TripStatus.error,
          locationIssue: LocationAccessStatus.serviceDisabled,
        ));
        return;
      }

      if (locationStatus != LocationAccessStatus.granted) {
        emit(state.copyWith(
          status: TripStatus.error,
          locationIssue: locationStatus,
        ));
        return;
      }

      final position = await repository.locationService.getCurrentLocation();
      final startLocation = LatLng(position.latitude, position.longitude);

      _currentTripId = await repository.startTrip(
        startLatitude: position.latitude,
        startLongitude: position.longitude,
      );

      _lastLocation = startLocation;
      _totalDistance = 0.0;
      _maxSpeed = 0.0;
      _routePoints = [startLocation];

      emit(state.copyWith(
        status: TripStatus.running,
        tripId: _currentTripId,
        currentLocation: startLocation,
        startLocation: startLocation,
        routePoints: _routePoints,
        tripStartTime: DateTime.now(),
      ));

      // START 10-SECOND LOCATION TIMER
      _startLocationTracking();
    } catch (e) {
      emit(state.copyWith(
        status: TripStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _startLocationTracking() {
    _locationTimer?.cancel();

    _locationTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        final position = await repository.locationService.getCurrentLocation();
        final newLocation = LatLng(position.latitude, position.longitude);
        final speed = position.speed * 3.6; // Convert m/s to km/h

        if (_lastLocation != null && _currentTripId != null) {
          // Calculate distance between last and current location
          final distance = _calculateDistance(_lastLocation!, newLocation);

          // Only draw line if moved more than 5 meters
          if (distance > 0.005) {
            _totalDistance += distance;
            _routePoints.add(newLocation); // Add to polyline
            _lastLocation = newLocation;

            if (speed > _maxSpeed) {
              _maxSpeed = speed;
            }

            // Save location to database
            final locationModel = LocationModel(
              tripId: _currentTripId!,
              latitude: newLocation.latitude,
              longitude: newLocation.longitude,
              speed: speed,
              timestamp: DateTime.now(),
            );
            await repository.saveLocation(locationModel);

            // Update trip data
            await repository.updateTripData(
              tripId: _currentTripId!,
              distance: _totalDistance,
              currentSpeed: speed,
              maxSpeed: _maxSpeed,
              latitude: newLocation.latitude,
              longitude: newLocation.longitude,
            );

            // Calculate average speed
            final tripStartTime = state.tripStartTime;
            double avgSpeed = 0.0;
            if (tripStartTime != null) {
              final elapsedSeconds = DateTime.now().difference(tripStartTime).inSeconds;
              if (elapsedSeconds > 0) {
                avgSpeed = (_totalDistance * 3600) / elapsedSeconds;
              }
            }

            // EMIT NEW STATE - POLYLINE UPDATES ON MAP
            emit(state.copyWith(
              currentLocation: newLocation,
              distance: _totalDistance,
              currentSpeed: speed,
              maxSpeed: _maxSpeed,
              avgSpeed: avgSpeed,
              routePoints: List.from(_routePoints), // Blue line drawn here
            ));
          }
        }
      } catch (e) {
        print('Location update error: $e');
      }
    });
  }

  Future<void> _onEndTrip(
      EndTrip event,
      Emitter<TrackingState> emit,
      ) async {
    try {
      _locationTimer?.cancel();

      if (_currentTripId != null) {
        final activeTrip = await repository.getActiveTrip();
        if (activeTrip != null) {
          final completedTrip = activeTrip.copyWith(
            status: 'completed',
            endTime: DateTime.now(),
            totalDistance: _totalDistance,
            maxSpeed: _maxSpeed,
          );
          await repository.updateTrip(completedTrip);
        }
      }

      emit(state.copyWith(
        status: TripStatus.completed,
        distance: _totalDistance,
        maxSpeed: _maxSpeed,
      ));

      _currentTripId = null;
      _lastLocation = null;
      _totalDistance = 0.0;
      _maxSpeed = 0.0;
      _routePoints = [];
    } catch (e) {
      emit(state.copyWith(
        status: TripStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _locationTimer?.cancel();
    return super.close();
  }
}