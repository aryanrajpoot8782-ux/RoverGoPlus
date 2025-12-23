
import 'package:flutter/material.dart';
import 'screens/home/captain_home_screen.dart';
import 'screens/history/ride_history_screen.dart';
import 'screens/profile/captain_profile_screen.dart';
import 'screens/trip/captain_trip_screen.dart';
import 'screens/splash_screen.dart';

class Routes {
  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const CaptainHomeScreen());
      case '/history':
        return MaterialPageRoute(builder: (_) => const RideHistoryScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const CaptainProfileScreen());
      case '/trip':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (_) => CaptainTripScreen(ride: args ?? const {}));
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
