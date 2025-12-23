
import 'dart:async';
import 'package:flutter/material.dart';

class LiveFareMeter extends StatefulWidget {
  const LiveFareMeter({super.key});

  @override
  State<LiveFareMeter> createState() => _LiveFareMeterState();
}

class _LiveFareMeterState extends State<LiveFareMeter> {
  double _distance = 0;
  double _fare = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() {
        _distance += 0.2;
        _fare = 30 + _distance * 12;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Live Fare Meter', style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Distance: ${_distance.toStringAsFixed(2)} km"),
            Text("Fare: ₹ ${_fare.toStringAsFixed(2)}"),
          ],
        ),
      ),
    );
  }
}
