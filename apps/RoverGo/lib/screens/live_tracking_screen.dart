import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../socket/user_socket.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String rideId;
  final LatLng pickup;
  final LatLng drop;
  final String vehicleType; // "car" or "bike"

  const LiveTrackingScreen({
    super.key,
    required this.rideId,
    required this.pickup,
    required this.drop,
    required this.vehicleType,
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen>
    with TickerProviderStateMixin {
  GoogleMapController? mapController;

  late Marker captainMarker;
  late Marker pickupMarker;
  late Marker dropMarker;

  List<LatLng> polylinePoints = [];
  Set<Polyline> polyLines = {};

  late BitmapDescriptor captainIcon;

  LatLng? lastPos;
  LatLng? nextPos;

  late AnimationController movementController;
  late Animation<double> movementAnimation;

  @override
  void initState() {
    super.initState();

    _setVehicleIcon();

    pickupMarker = Marker(
      markerId: const MarkerId("pickup"),
      position: widget.pickup,
      infoWindow: const InfoWindow(title: "Pickup"),
    );

    dropMarker = Marker(
      markerId: const MarkerId("drop"),
      position: widget.drop,
      infoWindow: const InfoWindow(title: "Drop"),
    );

    captainMarker = Marker(
      markerId: const MarkerId("captain"),
      position: widget.pickup,
      icon: captainIcon,
      rotation: 0,
      anchor: const Offset(0.5, 0.5),
    );

    movementController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _drawRoutePolyline();
    _initSocketListener();
  }

  // ---------------------------------------------
  // VEHICLE ICON LOADING
  // ---------------------------------------------
 Future<void> _setVehicleIcon() async {

  captainIcon = await BitmapDescriptor.asset(
    const ImageConfiguration(size: Size(52, 52)),
    widget.vehicleType == "bike" ? "assets/bike.png" : "assets/car.png",
  );

  setState(() {});
}

  // ---------------------------------------------
  // DRAW PICKUP → DROP POLYLINE
  // ---------------------------------------------
  void _drawRoutePolyline() {
    polylinePoints = [widget.pickup, widget.drop];

    polyLines.add(
      Polyline(
        polylineId: const PolylineId("route"),
        points: polylinePoints,
        width: 5,
        color: Colors.blue,
      ),
    );
  }

  // ---------------------------------------------
  // SOCKET LISTENER
  // ---------------------------------------------
  void _initSocketListener() {
    UserSocket.connect();

    UserSocket.socket.on("ride:${widget.rideId}:location", (data) {
      final pos = LatLng(data['lat'], data['lng']);

      lastPos = captainMarker.position;
      nextPos = pos;

      _animateMovement(lastPos!, nextPos!);
    });
  }

  // ---------------------------------------------
  // ANIMATED MOVEMENT
  // ---------------------------------------------
  void _animateMovement(LatLng from, LatLng to) {
    movementAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: movementController, curve: Curves.easeInOut),
    );

    movementController.reset();

    movementController.addListener(() {
      final lat = from.latitude +
          (to.latitude - from.latitude) * movementAnimation.value;
      final lng = from.longitude +
          (to.longitude - from.longitude) * movementAnimation.value;

      final newPos = LatLng(lat, lng);

      final bearing = _calculateBearing(from, to);

      setState(() {
        captainMarker = captainMarker.copyWith(
          positionParam: newPos,
          rotationParam: bearing,
        );
      });

      mapController?.moveCamera(
        CameraUpdate.newLatLng(newPos),
      );
    });

    movementController.forward();
  }

  // ---------------------------------------------
  // BEARING CALCULATION
  // ---------------------------------------------
  double _calculateBearing(LatLng from, LatLng to) {
    double lat1 = from.latitude * (pi / 180);
    double lat2 = to.latitude * (pi / 180);
    double dLng = (to.longitude - from.longitude) * (pi / 180);

    double y = sin(dLng) * cos(lat2);
    double x = cos(lat1) * sin(lat2) -
        sin(lat1) * cos(lat2) * cos(dLng);

    return (atan2(y, x) * 180 / pi + 360) % 360;
  }

  // ---------------------------------------------
  // UI
  // ---------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Tracking")),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => mapController = controller,
            initialCameraPosition: CameraPosition(
              target: widget.pickup,
              zoom: 14,
            ),
            markers: {pickupMarker, dropMarker, captainMarker},
            polylines: polyLines,
          ),

          // --------------------------
          // BOTTOM RIDE UI
          // --------------------------
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 10),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Captain is on the way",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.grey.shade200,
                        child: Icon(
                          widget.vehicleType == "bike"
                              ? Icons.pedal_bike
                              : Icons.directions_car,
                          size: 30,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Captain Name", style: TextStyle(fontSize: 16)),
                          Text(
                            "Vehicle No: XX00YY1234",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 14),
                    ),
                    child: const Text(
                      "Cancel Ride",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
