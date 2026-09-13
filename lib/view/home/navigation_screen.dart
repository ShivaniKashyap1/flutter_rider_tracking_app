import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rider_tracking_app/bloc/navigation/navigation_bloc.dart';
import 'package:flutter_rider_tracking_app/bloc/navigation/navigation_state.dart';
import 'package:flutter_rider_tracking_app/utils/app_colors.dart';
import 'package:flutter_rider_tracking_app/view/home/home_screen.dart';
import 'package:flutter_rider_tracking_app/view/profile/profile_screen.dart';
import 'package:flutter_rider_tracking_app/view/tracking/trip_history_screen.dart';

import '../../bloc/navigation/navigation_event.dart';

class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationBloc(),
    child: NavigationView(),
    );
  }
}

class NavigationView extends StatelessWidget {
  const NavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc,NavigationState>(
        builder: (context,state){
          final List<Widget> screens = [
            HomeScreen(),
            TripHistoryScreen(),
            ProfileScreen(),
          ];
          return Scaffold(
            backgroundColor: AppColors.screenBgColor,
            body: screens[state.selectedIndex],

              bottomNavigationBar: BottomNavigationBar(
                currentIndex: state.selectedIndex,

                onTap: (index) {
                  context.read<NavigationBloc>().add(
                    NavigationTabChanged(index),
                  );
                },

                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.business_center_outlined),
                    activeIcon: Icon(Icons.business_center),
                    label: 'Trips',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
          );
        },
        );
  }
}

