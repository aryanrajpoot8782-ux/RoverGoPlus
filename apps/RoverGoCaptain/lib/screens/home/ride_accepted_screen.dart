// ride_accepted_screen.dart
import 'package:flutter/material.dart';

class RideAcceptedScreen extends StatelessWidget {
  const RideAcceptedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ride Accepted')),
      body: Center(child: Text('You have accepted the ride!')),
    );
  }
}
