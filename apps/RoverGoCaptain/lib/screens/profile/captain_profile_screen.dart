
import 'package:flutter/material.dart';
import '../../api/captain_api.dart';

class CaptainProfileScreen extends StatefulWidget {
  const CaptainProfileScreen({super.key});

  @override
  State<CaptainProfileScreen> createState() => _CaptainProfileScreenState();
}

class _CaptainProfileScreenState extends State<CaptainProfileScreen> {
  Map<String, dynamic>? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    profile = await CaptainApi.fetchCaptainProfile("captain_001");
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile!['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("Phone: ${profile!['phone']}"),
                  const SizedBox(height: 10),
                  const Text("Vehicle", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Make: ${profile!['vehicle']['make']}"),
                  Text("Model: ${profile!['vehicle']['model']}"),
                  Text("Number: ${profile!['vehicle']['number']}"),
                ],
              ),
            ),
    );
  }
}
