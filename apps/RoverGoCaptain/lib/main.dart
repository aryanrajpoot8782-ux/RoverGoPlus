// lib/main.dart
import 'package:flutter/material.dart';
import 'routes.dart';
import 'screens/splash_screen.dart';
import 'screens/home/captain_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RoverGoCaptainApp());
}

class RoverGoCaptainApp extends StatelessWidget {
  const RoverGoCaptainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoverGo+ Captain',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),

      // If you have a Routes.generate function, use it; otherwise the app will
      // fall back to the routes map below. Ensure Routes.generate is defined
      // in lib/routes.dart if you want deep-link / dynamic route handling.
      onGenerateRoute: Routes.generate,

      // initialRoute + routes map for simple navigation.
      // SplashScreen will navigate (pushReplacementNamed) to '/home' when done.
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (ctx) => const SplashScreen(nextRoute: '/home'),
        '/home': (ctx) => const CaptainHomeScreen(),
        // add other static routes here if needed
      },
    );
  }
}
