import 'package:flutter/material.dart';
import 'package:flutter_rider_tracking_app/data/services/trip_database.dart';

import '../../utils/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _totalTrips = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final trips = await TripDatabase.instance.getTotalTripsCount();
    if (mounted) {
      setState(() {
        _totalTrips = trips;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.screenBgColor,
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // AVATAR + NAME
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: AppColors.mainAppColorBlue,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Rider',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              // STATS CARD
              Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statColumn(
                        icon: Icons.route,
                        value: '$_totalTrips',
                        label: 'Trips Completed',
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: const Color(0xFFE0E0E0),
                      ),
                      _statColumn(
                        icon: Icons.star,
                        value: '4.8',
                        label: 'Rating',
                        iconColor: Colors.amber,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statColumn({
    required IconData icon,
    required String value,
    required String label,
    Color iconColor = AppColors.mainAppColorBlue,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 26),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}