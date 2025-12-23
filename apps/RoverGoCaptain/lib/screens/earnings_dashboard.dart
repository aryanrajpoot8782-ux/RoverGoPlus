import 'package:flutter/material.dart';
import '../../api/captain_api.dart';

class EarningsDashboard extends StatefulWidget {
  const EarningsDashboard({super.key});

  @override
  State<EarningsDashboard> createState() => _EarningsDashboardState();
}

class _EarningsDashboardState extends State<EarningsDashboard> {
  bool _loading = true;
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    _loadEarnings();
  }

  Future<void> _loadEarnings() async {
    final id = await CaptainApi.captainId ?? "captain_001";

    final res = await CaptainApi.getEarnings(id);
    if (!mounted) return;

    setState(() {
      data = res;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Earnings")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _tile("Today", "₹${data!['today']}"),
                  _tile("Weekly", "₹${data!['weekly']}"),
                  _tile("Monthly", "₹${data!['monthly']}"),
                ],
              ),
            ),
    );
  }

  Widget _tile(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade200,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(title), Text(value)],
      ),
    );
  }
}
