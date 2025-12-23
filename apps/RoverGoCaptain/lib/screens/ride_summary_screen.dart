// lib/screens/ride_summary_screen.dart
import 'package:flutter/material.dart';

class RideSummaryScreen extends StatelessWidget {
  final Map<String, dynamic> ride;
  final double distanceKm;
  final int durationSeconds;
  final double fare;
  final String paymentMode;

  const RideSummaryScreen({
    super.key,
    required this.ride,
    required this.distanceKm,
    required this.durationSeconds,
    required this.fare,
    required this.paymentMode,
  });

  String _formatDuration(int seconds) {
    final d = Duration(seconds: seconds);
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final secs = d.inSeconds.remainder(60);
    if (hours > 0) return "${hours}h ${minutes}m";
    if (minutes > 0) return "${minutes}m ${secs}s";
    return "${secs}s";
  }

  @override
  Widget build(BuildContext context) {
    final riderName = ride['rider_name'] ?? ride['user'] ?? 'Rider';
    final rideId = ride['id'] ?? ride['_id'] ?? ride['rideId'] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Ride Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),

            /// ✔ FIX HERE
            Text('Trip Complete', style: Theme.of(context).textTheme.titleLarge),

            const SizedBox(height: 16),

            ListTile(
              leading: const Icon(Icons.person),
              title: Text(riderName),
              subtitle: Text('Ride ID: $rideId'),
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.map),
              title: Text('${distanceKm.toStringAsFixed(2)} km'),
              subtitle: const Text('Distance'),
            ),

            ListTile(
              leading: const Icon(Icons.timer),
              title: Text(_formatDuration(durationSeconds)),
              subtitle: const Text('Duration'),
            ),

            ListTile(
              leading: const Icon(Icons.attach_money),
              title: Text('₹ ${fare.toStringAsFixed(2)}'),
              subtitle: const Text('Fare'),
            ),

            ListTile(
              leading: const Icon(Icons.payment),
              title: Text(paymentMode),
              subtitle: const Text('Payment Mode'),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Finish'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
