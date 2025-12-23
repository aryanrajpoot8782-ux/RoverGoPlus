import 'package:flutter/material.dart';

class RideRequestPopup extends StatelessWidget {
  final Map<String, dynamic> ride;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const RideRequestPopup({
    super.key,
    required this.ride,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final pickup = ride['pickup_address'] ?? ride['pickup'] ?? 'Unknown pickup';
    final drop = ride['drop_address'] ?? ride['drop'] ?? 'Unknown drop';
    final rider = ride['rider_name'] ?? ride['user'] ?? 'Rider';

    return AlertDialog(
      title: Text('New Ride Request from $rider'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pickup: $pickup'),
          const SizedBox(height: 8),
          Text('Drop: $drop'),
          if (ride['fare'] != null) ...[
            const SizedBox(height: 8),
            Text('Estimated fare: ${ride['fare']}'),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: onDecline,
          child: const Text("Decline"),
        ),
        ElevatedButton(
          onPressed: onAccept,
          child: const Text("Accept"),
        ),
      ],
    );
  }
}
