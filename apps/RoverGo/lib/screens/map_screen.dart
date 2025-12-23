// lib/screens/map_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../utils/socket.dart';
import '../../api/rider_api.dart';
import 'waiting_for_captain_screen.dart';

class RiderMapScreen extends StatefulWidget {
  const RiderMapScreen({super.key});

  @override
  State<RiderMapScreen> createState() => _RiderMapScreenState();
}

class _RiderMapScreenState extends State<RiderMapScreen> {
  GoogleMapController? mapController;

  LatLng? currentPos;
  LatLng? pickup;
  LatLng? drop;

  bool requestingRide = false;
  bool loadingLocation = true;

  @override
  void initState() {
    super.initState();
    _initLocation();
    RiderSocket.connect();

    // Listen for ride acceptance
    RiderSocket.socket?.on("rider:ride_accepted", (rideData) {
      if (!mounted) return;

      final ride = Map<String, dynamic>.from(rideData);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WaitingForCaptainScreen(ride: ride),
        ),
      );
    });
  }

  // ------------------ GET CURRENT LOCATION ------------------
  Future<void> _initLocation() async {
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!mounted) return;

      if (!enabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enable Location Service")),
        );
        if (mounted) setState(() => loadingLocation = false);
        return;
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (!mounted) return;

      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (!mounted) return;
      }

      if (perm == LocationPermission.deniedForever ||
          perm == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location Permission Denied")),
          );
          setState(() => loadingLocation = false);
        }
        return;
      }

      Position p = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;

      setState(() {
        currentPos = LatLng(p.latitude, p.longitude);
        loadingLocation = false;
      });
    } catch (e) {
      debugPrint("Location Error: $e");

      if (!mounted) return;
      setState(() => loadingLocation = false);
    }
  }

  // ------------------ SEND RIDE REQUEST ------------------
  void requestRide() async {
    if (pickup == null || drop == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select Pick-up and Drop first")),
      );
      return;
    }

    if (RiderApi.riderId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Rider not logged in")),
      );
      return;
    }

    if (!mounted) return;
    setState(() => requestingRide = true);

    try {
      final res = await RiderApi.requestRide(
        RiderApi.riderId!,
        pickup!.latitude,
        pickup!.longitude,
        drop!.latitude,
        drop!.longitude,
      );

      if (!mounted) return;

      final ride = res["ride"] ?? res;

      // Send to captain sockets
      RiderSocket.socket?.emit("rider:request_ride", ride);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ride Request Sent!")),
        );
      }
    } catch (e) {
      debugPrint("Ride Request Error: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Request failed: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => requestingRide = false);
      }
    }
  }

  // ------------------ UI ------------------
  @override
  Widget build(BuildContext context) {
    if (loadingLocation) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (currentPos == null) {
      return const Scaffold(
        body: Center(child: Text("Unable to get your location")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Rider Map")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: currentPos!,
          zoom: 15,
        ),
        onMapCreated: (controller) => mapController = controller,
        onTap: (LatLng pos) {
          setState(() {
            if (pickup == null) {
              pickup = pos;
            } else if (drop == null) {
              drop = pos;
            } else {
              pickup = pos;
              drop = null;
            }
          });
        },
        markers: {
          if (pickup != null)
            Marker(
              markerId: const MarkerId("pickup"),
              position: pickup!,
              infoWindow: const InfoWindow(title: "Pickup"),
            ),
          if (drop != null)
            Marker(
              markerId: const MarkerId("drop"),
              position: drop!,
              infoWindow: const InfoWindow(title: "Drop"),
            ),
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: requestingRide ? null : requestRide,
        label: requestingRide
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text("Request Ride"),
      ),
    );
  }
}
