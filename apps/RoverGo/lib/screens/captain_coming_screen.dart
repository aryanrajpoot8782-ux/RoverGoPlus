// lib/screens/captain_coming_screen.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../utils/socket.dart';

class CaptainComingScreen extends StatefulWidget {
  final Map<String, dynamic> ride;

  const CaptainComingScreen({
    super.key,
    required this.ride,
  });

  @override
  State<CaptainComingScreen> createState() => _CaptainComingScreenState();
}

class _CaptainComingScreenState extends State<CaptainComingScreen> {
  GoogleMapController? mapController;

  LatLng? captainLocation;
  late LatLng pickupLocation;

  // IMPORTANT: socket.on() returns Function (remover), NOT StreamSubscription
  Function? captainLocationRemover;

  @override
  void initState() {
    super.initState();

    // Extract pickup coordinates from ride map
    pickupLocation = LatLng(
      widget.ride["pickup"]["lat"],
      widget.ride["pickup"]["lng"],
    );

    _listenToCaptainLocation();
  }

  // ------------------------------------------------------
  // SOCKET LISTENER FOR CAPTAIN LIVE LOCATION
  // ------------------------------------------------------
  void _listenToCaptainLocation() {
    captainLocationRemover = RiderSocket.socket?.on(
      "captain:location_update",
      (data) {
        if (!mounted) return;

        final loc = Map<String, dynamic>.from(data);

        setState(() {
          captainLocation = LatLng(loc["lat"], loc["lng"]);
        });

        // Auto-animate map camera to captain
        if (mapController != null) {
          mapController!.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(loc["lat"], loc["lng"]),
            ),
          );
        }
      },
    );
  }

  // ------------------------------------------------------
  // REMOVE SOCKET LISTENER ON DISPOSE
  // ------------------------------------------------------
  @override
  void dispose() {
    captainLocationRemover?.call(); // remove listener
    super.dispose();
  }

  // ------------------------------------------------------
  // UI
  // ------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Captain is Coming")),

      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: pickupLocation,
          zoom: 15,
        ),
        onMapCreated: (controller) => mapController = controller,

        markers: {
          // Pickup Marker
          Marker(
            markerId: const MarkerId("pickup"),
            position: pickupLocation,
            infoWindow: const InfoWindow(title: "Pickup Location"),
          ),

          // Live Captain Marker
          if (captainLocation != null)
            Marker(
              markerId: const MarkerId("captain"),
              position: captainLocation!,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              ),
              infoWindow: const InfoWindow(title: "Captain"),
            ),
        },
      ),

      // Bottom info bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        color: Colors.white,
        child: Row(
          children: [
            const CircleAvatar(
              radius: 26,
              backgroundColor: Colors.blue,
              child: Icon(Icons.motorcycle, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                captainLocation == null
                    ? "Waiting for captain's live location..."
                    : "Captain is on the way!",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
