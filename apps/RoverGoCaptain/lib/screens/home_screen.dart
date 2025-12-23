// lib/screens/captain_home_screen.dart

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../api/captain_api.dart';

class CaptainHomeScreen extends StatefulWidget {
  const CaptainHomeScreen({super.key});

  @override
  State<CaptainHomeScreen> createState() => _CaptainHomeScreenState();
}

class _CaptainHomeScreenState extends State<CaptainHomeScreen> {
  io.Socket? socket;
  bool isOnline = false;
  bool connecting = false;
  Map<String, dynamic>? incomingRide;

  static const String socketUrl = "http://10.0.2.2:4000";

  @override
  void initState() {
    super.initState();
    _connectSocket();
  }

  // ----------------------------------------------------------------------
  // CONNECT SOCKET
  // ----------------------------------------------------------------------
  void _connectSocket() {
    if (socket != null && socket!.connected) return;

    setState(() => connecting = true);

    socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .enableAutoConnect()
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      debugPrint("Captain connected: ${socket!.id}");

      // Let backend know captain is online in socket
      socket!.emit("captain:join", {
        "captainId": CaptainApi.captainId,
      });

      if (!mounted) return;
      setState(() => connecting = false);
    });

    socket!.onDisconnect((_) {
      debugPrint("Disconnected from socket");
      if (!mounted) return;

      setState(() {
        isOnline = false;
        connecting = false;
      });
    });

    socket!.onConnectError((err) {
      debugPrint("Connection error: $err");
      if (!mounted) return;
      setState(() => connecting = false);
    });

    // ------------------------------------------------------------------
    // FIXED: LISTEN FOR NEW RIDE REQUEST
    // ------------------------------------------------------------------
    socket!.on("captain:new_ride", (rideData) {
      debugPrint("Incoming ride request: $rideData");

      if (!mounted) return;

      setState(() {
        incomingRide = Map<String, dynamic>.from(rideData);
      });
    });

    // ACK - rider notified
    socket!.on("ride:confirmed", (data) {
      debugPrint("Ride confirmed ack: $data");
    });
  }

  // ----------------------------------------------------------------------
  // GO ONLINE
  // ----------------------------------------------------------------------
  void _goOnline() {
    if (socket == null || socket!.disconnected) {
      _connectSocket();
    }

    socket?.emit("captain:go_online", {
      "captainId": CaptainApi.captainId,
    });

    if (!mounted) return;
    setState(() => isOnline = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You are now online")),
    );
  }

  // ----------------------------------------------------------------------
  // ACCEPT RIDE
  // ----------------------------------------------------------------------
  void _acceptRide() {
    if (incomingRide == null) return;

    final rideId = incomingRide!["rideId"];

    socket?.emit("captain:accept_ride", {
      "rideId": rideId,
      "captainId": CaptainApi.captainId,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ride accepted")),
    );

    setState(() {
      incomingRide = null;
    });
  }

  // ----------------------------------------------------------------------
  // DECLINE RIDE
  // ----------------------------------------------------------------------
  void _declineRide() {
    if (incomingRide == null) return;

    final rideId = incomingRide!["rideId"];

    socket?.emit("captain:reject_ride", {
      "rideId": rideId,
      "captainId": CaptainApi.captainId,
    });

    setState(() => incomingRide = null);
  }

  @override
  void dispose() {
    socket?.disconnect();
    socket?.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------------------
  // UI SECTION
  // ----------------------------------------------------------------------
  Widget _rideCard() {
    final pickup = incomingRide?["pickup"] ?? "Unknown pickup";
    final drop = incomingRide?["dropoff"] ?? "Unknown drop";
    final fare = incomingRide?["fare"]?.toString() ?? "-";

    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("New Ride Request",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Pickup: $pickup"),
            Text("Drop: $drop"),
            Text("Estimated Fare: ₹$fare"),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _acceptRide,
                    child: const Text("Accept Ride"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _declineRide,
                    child: const Text("Decline"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _statusIndicator() {
    if (connecting) {
      return Row(
        children: const [
          CircularProgressIndicator(strokeWidth: 2),
          SizedBox(width: 8),
          Text("Connecting...")
        ],
      );
    }

    return Row(
      children: [
        Icon(
          isOnline ? Icons.toggle_on : Icons.toggle_off,
          color: isOnline ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(isOnline ? "Online" : "Offline"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Captain Dashboard"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: _statusIndicator()),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: isOnline ? null : _goOnline,
              icon: const Icon(Icons.wifi),
              label: Text(isOnline ? "Online" : "Go Online"),
            ),
            const SizedBox(height: 20),
            if (incomingRide == null)
              Expanded(
                child: Center(
                  child: Text(
                    isOnline
                        ? "Waiting for ride requests..."
                        : "Go online to start receiving rides",
                    style: const TextStyle(fontSize: 17),
                  ),
                ),
              )
            else
              _rideCard(),
          ],
        ),
      ),
    );
  }
}
