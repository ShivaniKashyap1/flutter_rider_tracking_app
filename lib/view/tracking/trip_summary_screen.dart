import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class TripSummaryScreen extends StatelessWidget {
  final LatLng? startLocation;
  final LatLng? endLocation;
  final DateTime? startTime;
  final DateTime? endTime;
  final double totalDistance;
  final double avgSpeed;
  final double maxSpeed;

  const TripSummaryScreen({
    super.key,
    required this.startLocation,
    required this.endLocation,
    required this.startTime,
    required this.endTime,
    required this.totalDistance,
    required this.avgSpeed,
    required this.maxSpeed,
  });

  String _formatDuration() {
    if (startTime == null || endTime == null) return '--:--:--';
    final diff = endTime!.difference(startTime!);
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
        ),
        title: const Text('Trip Summary', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 6),
                  const Text('Trip Completed',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _statCard('Total Distance', '${totalDistance.toStringAsFixed(2)} km'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statCard('Total Time', _formatDuration()),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _statCard('Avg Speed', '${avgSpeed.toStringAsFixed(0)} km/h'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statCard('Max Speed', '${maxSpeed.toStringAsFixed(0)} km/h'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (startLocation != null && endLocation != null)
                SizedBox(
                  height: 180,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(target: startLocation!, zoom: 13),
                      markers: {
                        Marker(
                          markerId: const MarkerId('start'),
                          position: startLocation!,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueGreen),
                        ),
                        Marker(
                          markerId: const MarkerId('end'),
                          position: endLocation!,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed),
                        ),
                      },
                      polylines: {
                        Polyline(
                          polylineId: const PolylineId('summaryRoute'),
                          points: [startLocation!, endLocation!],
                          width: 4,
                        ),
                      },
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              _locationRow('Start Location', startLocation),
              const SizedBox(height: 8),
              _locationRow('End Location', endLocation),
              const SizedBox(height: 8),
              _dateRow(),

            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _locationRow(String label, LatLng? loc) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(
          loc == null
              ? '--'
              : '${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}',
        ),
      ],
    );
  }

  Widget _dateRow() {
    final formatted = startTime == null
        ? '--'
        : DateFormat('dd MMM yyyy, hh:mm a').format(startTime!);
    return Row(
      children: [
        const Text('Date & Time: ', style: TextStyle(fontWeight: FontWeight.w600)),
        Text(formatted),
      ],
    );
  }
}