class TripTrackingModel {
  final int? id;
  final String status;
  final DateTime startTime;
  final DateTime? endTime;
  final double totalDistance;
  final double currentSpeed;
  final double maxSpeed;
  final double? latitude;
  final double? longitude;
  final double? startLatitude;
  final double? startLongitude;

  TripTrackingModel({
    this.id,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.totalDistance,
    required this.currentSpeed,
    required this.maxSpeed,
    this.latitude,
    this.longitude, this.startLatitude, this.startLongitude,
  });



  TripTrackingModel copyWith({
    int? id,
    String? status,
    DateTime? startTime,
    DateTime? endTime,
    double? totalDistance,
    double? currentSpeed,
    double? maxSpeed,
    double? latitude,
    double? longitude,
    double? startLatitude,
    double? startLongitude,
  }) {
    return TripTrackingModel(
      id: id ?? this.id,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalDistance: totalDistance ?? this.totalDistance,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      startLatitude: startLatitude ?? this.startLatitude,
      startLongitude: startLongitude ?? this.startLongitude,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'total_distance': totalDistance,
      'current_speed': currentSpeed,
      'max_speed': maxSpeed,
      'latitude': latitude,
      'longitude': longitude,
      'start_latitude': startLatitude,
      'start_longitude': startLongitude,
    };
  }



  factory TripTrackingModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return TripTrackingModel(
      id: map['id'] as int?,
      status: map['status'] as String,
      startTime:
      DateTime.parse(map['start_time'] as String),
      endTime: map['end_time'] == null
          ? null
          : DateTime.parse(
        map['end_time'] as String,
      ),
      totalDistance:
      (map['total_distance'] as num).toDouble(),
      currentSpeed:
      (map['current_speed'] as num).toDouble(),
      maxSpeed:
      (map['max_speed'] as num).toDouble(),
      latitude:
      (map['latitude'] as num?)?.toDouble(),
      longitude:
      (map['longitude'] as num?)?.toDouble(),

      startLatitude: (map['start_latitude'] as num?)?.toDouble(),
      startLongitude: (map['start_longitude'] as num?)?.toDouble(),

    );
  }
}