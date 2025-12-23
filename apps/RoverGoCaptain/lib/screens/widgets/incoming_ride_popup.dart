
import 'package:flutter/material.dart';

class IncomingRidePopup extends StatelessWidget {
  const IncomingRidePopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Incoming Ride'),
      content: const Text("Pickup: Airport → Drop: City Center"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Decline')),
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/trip', arguments: {'id': 'ride_001'}),
          child: const Text('Accept'),
        )
      ],
    );
  }
}
