import 'package:flutter/material.dart';

class WaitingForCaptainScreen extends StatelessWidget {
  final Map<String, dynamic> ride;

  const WaitingForCaptainScreen({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    final captain = ride["captain"] ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text("Captain Assigned")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Captain is on the way!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Text("Captain Name: ${captain["name"] ?? "Unknown"}"),
            Text("Phone: ${captain["phone"] ?? "-"}"),

            const SizedBox(height: 15),

            Text("Pickup: ${ride["pickup"] ?? "-"}"),
            Text("Drop: ${ride["dropoff"] ?? "-"}"),
            Text("Fare: ₹${ride["fare"] ?? "-"}"),

            const SizedBox(height: 30),

            const Center(
              child: CircularProgressIndicator(),
            ),

            const SizedBox(height: 10),

            const Center(
              child: Text("Please wait while your captain arrives..."),
            )
          ],
        ),
      ),
    );
  }
}
