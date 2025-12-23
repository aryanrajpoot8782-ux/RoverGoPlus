import 'package:flutter/material.dart';

class WaitingForCaptainScreen extends StatelessWidget {
  final Map ride;

  const WaitingForCaptainScreen({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Captain Assigned")),
      body: Center(
        child: Text(
          "Captain Assigned!\nRide ID: ${ride['id']}",
          style: const TextStyle(fontSize: 22),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
