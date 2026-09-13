import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/services/location_service.dart';

enum TripStatus {
  initial,
  running,
  completed,
  error,
}

class TrackingState {
  final TripStatus status;
  final int? tripId;

  final double distance;
  final double currentSpeed;
  final double maxSpeed;
  final double avgSpeed;

  final LatLng? currentLocation;
  final List<LatLng> routePoints;

  final String? errorMessage;
  final LocationAccessStatus? locationIssue;

  final LatLng? startLocation;
  final DateTime? tripStartTime;
  final DateTime? tripEndTime;

  const TrackingState({
    this.status = TripStatus.initial,
    this.tripId,
    this.distance = 0,
    this.currentSpeed = 0,
    this.maxSpeed = 0,
    this.avgSpeed = 0,
    this.currentLocation,
    this.routePoints = const [],
    this.errorMessage,
    this.locationIssue,
    this.startLocation,
    this.tripStartTime,
    this.tripEndTime,
  });

  TrackingState copyWith({
    TripStatus? status,
    int? tripId,
    double? distance,
    double? currentSpeed,
    double? maxSpeed,
    double? avgSpeed,
    LatLng? currentLocation,
    List<LatLng>? routePoints,
    String? errorMessage,
    LocationAccessStatus? locationIssue,
    LatLng? startLocation,
    DateTime? tripStartTime,
    DateTime? tripEndTime,
  }) {
    return TrackingState(
      status: status ?? this.status,
      tripId: tripId ?? this.tripId,
      distance: distance ?? this.distance,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      avgSpeed: avgSpeed ?? this.avgSpeed,
      currentLocation: currentLocation ?? this.currentLocation,
      routePoints: routePoints ?? this.routePoints,
      errorMessage: errorMessage ?? this.errorMessage,
      locationIssue: locationIssue ?? this.locationIssue,
      startLocation: startLocation ?? this.startLocation,
      tripStartTime: tripStartTime ?? this.tripStartTime,
      tripEndTime: tripEndTime ?? this.tripEndTime,
    );
  }
}