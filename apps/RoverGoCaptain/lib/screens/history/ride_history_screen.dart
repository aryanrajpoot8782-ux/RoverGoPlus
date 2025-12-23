
import 'package:flutter/material.dart';
import '../../api/captain_api.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  List<Map<String, dynamic>> rides = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    rides = await CaptainApi.fetchRideHistory('captain_001');
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ride History')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: rides
                  .map(
                    (r) => ListTile(
                      title: Text("${r['pickup']} → ${r['drop']}"),
                      subtitle: Text("₹${r['fare']} • ${r['date']}"),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
