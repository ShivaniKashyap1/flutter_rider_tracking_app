class LocationModel {
  final int? id;
  final int tripId;
  final double latitude;
  final double longitude;
  final double speed;
  final DateTime timestamp;

  LocationModel({
    this.id,
    required this.tripId,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      id: map['id'] as int?,
      tripId: map['trip_id'] as int,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      speed: (map['speed'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  @override
  String toString() {
    return 'Lat: ${latitude.toStringAsFixed(4)}, Lng: ${longitude.toStringAsFixed(4)}, Speed: ${speed.toStringAsFixed(1)} km/h, Time: ${timestamp.hour}:${timestamp.minute}:${timestamp.second}';
  }
}