import 'package:flutter/material.dart';
import 'package:flutter_rider_tracking_app/data/services/trip_database.dart';
import 'package:flutter_rider_tracking_app/model/trip_tracking_model.dart';
import 'package:flutter_rider_tracking_app/view/tracking/trip_summary_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../../utils/app_colors.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  List<TripTrackingModel> _trips = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    final trips = await TripDatabase.instance.getAllCompletedTrips();
    if (mounted) {
      setState(() {
        _trips = trips;
        _loading = false;
      });
    }
  }

  double _avgSpeed(TripTrackingModel trip) {
    if (trip.endTime == null) return 0;
    final elapsedHours =
        trip.endTime!.difference(trip.startTime).inSeconds / 3600.0;
    if (elapsedHours <= 0) return 0;
    return trip.totalDistance / elapsedHours;
  }

  String _timeRange(TripTrackingModel trip) {
    final startStr = DateFormat('hh:mm a').format(trip.startTime);
    final endStr = trip.endTime == null
        ? '--'
        : DateFormat('hh:mm a').format(trip.endTime!);
    return '$startStr - $endStr';
  }

  void _openSummary(TripTrackingModel trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TripSummaryScreen(
          startLocation: trip.startLatitude == null
              ? null
              : LatLng(trip.startLatitude!, trip.startLongitude!),
          endLocation: trip.latitude == null
              ? null
              : LatLng(trip.latitude!, trip.longitude!),
          startTime: trip.startTime,
          endTime: trip.endTime,
          totalDistance: trip.totalDistance,
          avgSpeed: _avgSpeed(trip),
          maxSpeed: trip.maxSpeed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBgColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: const [
                  Icon(Icons.arrow_back),
                  SizedBox(width: 10),
                  Text(
                    'Trip History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _trips.isEmpty
                  ? const Center(
                child: Text(
                  'No trips yet',
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : RefreshIndicator(
                onRefresh: _loadTrips,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  itemCount: _trips.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final trip = _trips[index];
                    return Dismissible(
                      key: ValueKey(trip.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Delete Trip'),
                            content: const Text(
                              'Are you sure you want to delete this trip? This cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        ) ??
                            false;
                      },
                      onDismissed: (direction) async {
                        await TripDatabase.instance.deleteTrip(trip.id!);
                        setState(() {
                          _trips.removeAt(index);
                        });
                      },
                      child: _tripCard(trip),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tripCard(TripTrackingModel trip) {
    return InkWell(
      onTap: () => _openSummary(trip),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F6FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.location_on, color: AppColors.mainAppColorBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd MMM yyyy').format(trip.startTime),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeRange(trip),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${trip.totalDistance.toStringAsFixed(2)} km  •  '
                        '${_avgSpeed(trip).toStringAsFixed(0)} km/h (avg)',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}