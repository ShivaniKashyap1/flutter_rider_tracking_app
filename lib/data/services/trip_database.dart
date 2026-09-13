import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../model/location_model.dart';
import '../../model/trip_tracking_model.dart';

class TripDatabase {
  static final TripDatabase instance = TripDatabase._internal();

  static Database? _database;

  TripDatabase._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'rider_tracker.db');

    return openDatabase(
      path,
      version: 3, // CHANGE FROM 2 TO 3
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE trips (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          status TEXT NOT NULL,
          start_time TEXT NOT NULL,
          end_time TEXT,
          total_distance REAL NOT NULL,
          current_speed REAL NOT NULL,
          max_speed REAL NOT NULL,
          latitude REAL,
          longitude REAL,
          start_latitude REAL,
          start_longitude REAL
        )
      ''');

        await db.execute('''
        CREATE TABLE trip_locations (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          trip_id INTEGER NOT NULL,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          speed REAL NOT NULL,
          timestamp TEXT NOT NULL
        )
      ''');

        await db.execute('''
        CREATE INDEX idx_trip_locations_trip_id
        ON trip_locations(trip_id)
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE trips ADD COLUMN start_latitude REAL');
          await db.execute('ALTER TABLE trips ADD COLUMN start_longitude REAL');
        }


        if (oldVersion == 2 && newVersion == 3) {

          final info = await db.rawQuery('PRAGMA table_info(trips)');
          final columnNames = info.map((col) => col['name']).toList();

          if (!columnNames.contains('start_latitude')) {
            await db.execute('ALTER TABLE trips ADD COLUMN start_latitude REAL');
          }
          if (!columnNames.contains('start_longitude')) {
            await db.execute('ALTER TABLE trips ADD COLUMN start_longitude REAL');
          }
        }
      },
    );
  }

  Future<int> createTrip(TripTrackingModel trip) async {
    final db = await database;

    return db.insert('trips', trip.toMap());
  }

  Future<void> updateTripData({
    required int tripId,
    required double distance,
    required double currentSpeed,
    required double maxSpeed,
    required double latitude,
    required double longitude,
  }) async {
    final db = await database;

    await db.update(
      'trips',
      {
        'total_distance': distance,
        'current_speed': currentSpeed,
        'max_speed': maxSpeed,
        'latitude': latitude,
        'longitude': longitude,
      },
      where: 'id = ?',
      whereArgs: [tripId],
    );
  }

  // ADD THIS METHOD
  Future<void> updateTrip(TripTrackingModel trip) async {
    final db = await database;

    await db.update(
      'trips',
      {
        'status': trip.status,
        'start_time': trip.startTime.toIso8601String(),
        'end_time': trip.endTime?.toIso8601String(),
        'total_distance': trip.totalDistance,
        'current_speed': trip.currentSpeed,
        'max_speed': trip.maxSpeed,
        'latitude': trip.latitude,
        'longitude': trip.longitude,
        'start_latitude': trip.startLatitude,
        'start_longitude': trip.startLongitude,
      },
      where: 'id = ?',
      whereArgs: [trip.id],
    );
  }

  Future<TripTrackingModel?> getLastCompletedTrip() async {
    final db = await database;

    final result = await db.query(
      'trips',
      where: 'status = ?',
      whereArgs: ['completed'],
      orderBy: 'end_time DESC',
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return TripTrackingModel.fromMap(result.first);
  }

  Future<List<TripTrackingModel>> getAllCompletedTrips() async {
    final db = await database;

    final result = await db.query(
      'trips',
      where: 'status = ?',
      whereArgs: ['completed'],
      orderBy: 'end_time DESC',
    );

    return result.map((row) => TripTrackingModel.fromMap(row)).toList();
  }

  Future<void> insertLocation(LocationModel location) async {
    final db = await database;

    await db.insert('trip_locations', location.toMap());
  }

  Future<TripTrackingModel?> getActiveTrip() async {
    final db = await database;

    final result = await db.query(
      'trips',
      where: 'status = ?',
      whereArgs: ['running'],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return TripTrackingModel.fromMap(result.first);
  }

  Future<int> getTotalTripsCount() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM trips WHERE status = 'completed'",
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> deleteTrip(int tripId) async {
    final db = await database;

    await db.delete(
      'trips',
      where: 'id = ?',
      whereArgs: [tripId],
    );


    await db.delete(
      'trip_locations',
      where: 'trip_id = ?',
      whereArgs: [tripId],
    );
  }

}


