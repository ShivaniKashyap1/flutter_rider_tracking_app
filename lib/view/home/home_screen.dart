import 'package:flutter/material.dart';
import 'package:flutter_rider_tracking_app/common_component/common_text_design.dart';
import 'package:flutter_rider_tracking_app/data/services/trip_database.dart';
import 'package:flutter_rider_tracking_app/model/trip_tracking_model.dart';
import 'package:flutter_rider_tracking_app/utils/app_colors.dart';
import 'package:flutter_rider_tracking_app/view/tracking/tracking_screen.dart';
import 'package:flutter_rider_tracking_app/view/tracking/trip_summary_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TripTrackingModel? _lastTrip;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLastTrip();
  }

  Future<void> _loadLastTrip() async {
    final trip = await TripDatabase.instance.getLastCompletedTrip();
    if (mounted) {
      setState(() {
        _lastTrip = trip;
        _loading = false;
      });
    }
  }

  String _formatDuration(TripTrackingModel trip) {
    if (trip.endTime == null) return '--:--:--';
    final diff = trip.endTime!.difference(trip.startTime);
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  double _avgSpeed(TripTrackingModel trip) {
    if (trip.endTime == null) return 0;
    final elapsedHours =
        trip.endTime!.difference(trip.startTime).inSeconds / 3600.0;
    if (elapsedHours <= 0) return 0;
    return trip.totalDistance / elapsedHours;
  }

  void _openTripSummary() {
    final trip = _lastTrip;
    if (trip == null) return;

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
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.screenBgColor,
        body: Padding(
          padding: const EdgeInsets.all(11.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.menu),

                  const Text(
                    'Rider Tracker',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.person,
                      size: 20,
                      color: AppColors.mainAppColorBlue,
                    ),
                  ),
                ],
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.04),

              // current Status Card
              Card(
                color: Colors.white,
                elevation: 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.03,
                    vertical: MediaQuery.of(context).size.height * 0.02,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      CommonTextDesign(
                        text: 'Current Status',
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.08,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F6FA),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                              MediaQuery.of(context).size.height * 0.02,
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Color(0xFF536B85),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Not Started',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TrackingScreen(),
                              ),
                            );
                            _loadLastTrip();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mainAppColorBlue,
                            elevation: 0,
                          ),
                          child: CommonTextDesign(
                            text: 'Start Trip',
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // last Trip card design..
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),

              SizedBox(
                width: double.infinity,
                child: Card(
                  color: Colors.white,
                  elevation: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05,
                      vertical: MediaQuery.of(context).size.height * 0.03,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CommonTextDesign(
                              text: 'Last Trip',
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            if (_lastTrip != null)
                              TextButton(
                                onPressed: _openTripSummary,
                                child: const Text('View Details'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 5),

                        if (_loading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (_lastTrip == null)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'No trips yet',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        else ...[
                            _tripInfo(
                              icon: Icons.calendar_today,
                              title: 'Date',
                              value: DateFormat('dd MMM yyyy, hh:mm a')
                                  .format(_lastTrip!.startTime),
                            ),
                            _tripInfo(
                              icon: Icons.location_on,
                              title: 'Distance',
                              value:
                              '${_lastTrip!.totalDistance.toStringAsFixed(2)} km',
                            ),
                            _tripInfo(
                              icon: Icons.speed,
                              title: 'Max Speed',
                              value:
                              '${_lastTrip!.maxSpeed.toStringAsFixed(0)} km/h',
                            ),
                          ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tripInfo({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.black, fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}