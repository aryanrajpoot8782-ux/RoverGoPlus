import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/captain_location_service.dart';
import '../../socket/captain_socket.dart';

class CaptainTripScreen extends StatefulWidget {
  final Map<String, dynamic> ride;

  const CaptainTripScreen({super.key, required this.ride});

  @override
  State<CaptainTripScreen> createState() => _CaptainTripScreenState();
}

class _CaptainTripScreenState extends State<CaptainTripScreen> {
  GoogleMapController? mapController;
  late Marker captainMarker;

  @override
  void initState() {
    super.initState();

    // Initial marker position (can be pickup or current)
    captainMarker = const Marker(
      markerId: MarkerId("captain"),
      position: LatLng(12.9716, 77.5946),
    );

    // Start sending location to backend
    CaptainLocationService.start(widget.ride['captainId']);

    // Listen for real-time updates from backend
    CaptainSocket.onLocationUpdate((data) {
      final LatLng newPos = LatLng(data['lat'], data['lng']);

      setState(() {
        captainMarker = captainMarker.copyWith(
          positionParam: newPos,
        );
      });

      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(newPos),
        );
      }
    });
  }

  @override
  void dispose() {
    CaptainLocationService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Active Trip")),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: GoogleMap(
              onMapCreated: (controller) => mapController = controller,
              markers: {captainMarker},
              initialCameraPosition: const CameraPosition(
                target: LatLng(12.9716, 77.5946),
                zoom: 14,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text("Ride ID: ${widget.ride['id']}"),
          ),
        ],
      ),
    );
  } 
}
