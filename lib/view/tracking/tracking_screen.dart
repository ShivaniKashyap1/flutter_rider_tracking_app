import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rider_tracking_app/bloc/tracking/tracking_bloc.dart';
import 'package:flutter_rider_tracking_app/bloc/tracking/tracking_event.dart';
import 'package:flutter_rider_tracking_app/bloc/tracking/tracking_state.dart';
import 'package:flutter_rider_tracking_app/data/repository/tracking_repository.dart';
import 'package:flutter_rider_tracking_app/data/services/location_service.dart';
import 'package:flutter_rider_tracking_app/data/services/trip_database.dart';
import 'package:flutter_rider_tracking_app/view/tracking/trip_summary_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../utils/app_colors.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TrackingBloc>(
      create: (_) => TrackingBloc(
        repository: TrackingRepository(
          database: TripDatabase.instance,
          locationService: LocationService(),
        ),
      )..add(StartTrip()),
      child: const _TrackingView(),
    );
  }
}

class _TrackingView extends StatefulWidget {
  const _TrackingView();

  @override
  State<_TrackingView> createState() => _TrackingViewState();
}

class _TrackingViewState extends State<_TrackingView> with WidgetsBindingObserver {
  bool _waitingForLocationEnable = false;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed && _waitingForLocationEnable) {
      _waitingForLocationEnable = false;

      final locationService =
          context.read<TrackingBloc>().repository.locationService;
      final isEnabled = await locationService.isLocationServiceEnabled();

      if (isEnabled && mounted) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Location Enabled'),
            content: const Text('Great! Starting your trip now.'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        if (mounted) {
          context.read<TrackingBloc>().add(StartTrip());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return  BlocListener<TrackingBloc, TrackingState>(
      listenWhen: (previous, current) =>
      (previous.status != TripStatus.completed &&
          current.status == TripStatus.completed) ||
          (previous.locationIssue != current.locationIssue &&
              current.locationIssue == LocationAccessStatus.serviceDisabled),
      listener: (context, state) {
        if (state.status == TripStatus.completed) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          return;

        }

        if (state.currentLocation != null && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(state.currentLocation!),
          );
        }


        if (state.locationIssue == LocationAccessStatus.serviceDisabled) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              title: const Text('Turn On Location'),
              content: const Text(
                'Your device location is off. Please turn it on to start tracking your trip.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    _waitingForLocationEnable = true;
                    await context
                        .read<TrackingBloc>()
                        .repository
                        .locationService
                        .openLocationSettings();
                  },
                  child: const Text('Turn On'),
                ),
              ],
            ),
          );
        }
      },
      child: BlocBuilder<TrackingBloc, TrackingState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.screenBgColor,
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.arrow_back,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Trip in Progress',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // MAP
                  Expanded(
                    child: state.status == TripStatus.error
                        ? Center(
                      child: Text(
                        state.errorMessage ?? 'Something went wrong',
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                        : state.currentLocation == null
                        ? const Center(
                      child: CircularProgressIndicator(),
                    )
                        : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: state.currentLocation!,
                        zoom: 16,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      markers: {
                        Marker(
                          markerId: const MarkerId('rider'),
                          position: state.currentLocation!,
                        ),
                      },
                      polylines: {
                        Polyline(
                          polylineId: const PolylineId('route'),
                          points: state.routePoints,
                          color: const Color(0xFF2E7DFA),
                          width: 5,
                          startCap: Cap.roundCap,
                          endCap: Cap.roundCap,
                          jointType: JointType.round,
                        ),
                      },
                      zoomControlsEnabled: false,
                    ),
                  ),

                  // TRIP INFORMATION
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        // STATUS
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Trip Running',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        // DISTANCE + CURRENT SPEED
                        Row(
                          children: [
                            Expanded(
                              child: _infoCard(
                                title: 'Distance',
                                value:
                                '${state.distance.toStringAsFixed(2)} km',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _infoCard(
                                title: 'Current Speed',
                                value:
                                '${state.currentSpeed.toStringAsFixed(0)} km/h',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // MAX SPEED + LOCATION
                        Row(
                          children: [
                            Expanded(
                              child: _infoCard(
                                title: 'Max Speed',
                                value:
                                '${state.maxSpeed.toStringAsFixed(0)} km/h',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _infoCard(
                                title: 'Location',
                                value: state.currentLocation == null
                                    ? '--'
                                    : '${state.currentLocation!.latitude.toStringAsFixed(4)}, '
                                    '${state.currentLocation!.longitude.toStringAsFixed(4)}',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        // END TRIP
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              context
                                  .read<TrackingBloc>()
                                  .add(EndTrip());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              'End Trip',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}