abstract class TrackingEvent {}

class StartTrip extends TrackingEvent {}

class LocationUpdated extends TrackingEvent {
  final double latitude;
  final double longitude;
  final double speed;

  LocationUpdated({
    required this.latitude,
    required this.longitude,
    required this.speed,
  });
}

class EndTrip extends TrackingEvent {}

class LoadActiveTrip extends TrackingEvent {}