import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../services/captain_location_service.dart';
import '../../socket/captain_socket.dart';

class CaptainHomeScreen extends StatefulWidget {
  const CaptainHomeScreen({super.key});

  @override
  State<CaptainHomeScreen> createState() => _CaptainHomeScreenState();
}

class _CaptainHomeScreenState extends State<CaptainHomeScreen> {
  bool _online = false;
  GoogleMapController? _mapController;
  Marker? _captainMarker;
  LatLng? _lastPosition;
  double _heading = 0.0;

  StreamSubscription<Position?>? _positionSub;

  final String _captainId = "your_real_captain_id";
  final String _socketUrl = "http://your.backend.server:4000";

  @override
  void initState() {
    super.initState();
    // Connect socket early (optional). We'll connect when going online too.
    CaptainSocket.connect(_socketUrl, onConnect: () {
      debugPrint("Captain socket connected");
    });

    // Subscribe to foreground location stream to update the map while app is foreground.
    _subscribeForegroundLocation();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    CaptainSocket.dispose();
    super.dispose();
  }

  void _subscribeForegroundLocation() {
    // Use Geolocator's position stream to update the map marker while app is in foreground.
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5, // update every ~5 meters
    );

    _positionSub = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position? pos) {
        if (pos == null) return;
        final LatLng newPos = LatLng(pos.latitude, pos.longitude);

        setState(() {
          _lastPosition = newPos;
          _heading = pos.heading.isNaN ? 0.0 : pos.heading;
          _captainMarker = Marker(
            markerId: const MarkerId('captain'),
            position: newPos,
            rotation: _heading,
            anchor: const Offset(0.5, 0.5),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          );
        });

        // Move camera to follow captain
        if (_mapController != null) {
          _mapController!.animateCamera(CameraUpdate.newLatLng(newPos));
        }
      },
      onError: (err) {
        debugPrint("Position stream error: $err");
      },
    );
  }

  Future<bool> _ensurePermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // user rejected permanently
      return false;
    }

    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  Future<void> toggleOnline(bool value) async {
    // Toggle local UI state immediately for responsiveness
    setState(() => _online = value);

    if (value) {
      // Going online: request permission, connect socket and start background service
      final ok = await _ensurePermissions();
      if (!ok) {
        // Show dialog explaining permissions
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Location permission required'),
            content: const Text(
              'To go online and receive rides you must allow location access (foreground and background). Please enable it in settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        setState(() => _online = false);
        return;
      }

      // Connect socket (reconnect if needed)
      CaptainSocket.connect(_socketUrl, onConnect: () {
        debugPrint("Connected to socket when going online");
        // Emit captain join so server marks us online (server expects this event name)
        CaptainSocket.socket?.emit("captain:join", {"captainId": _captainId});
      });

      // Start background location streaming (service will forward location to server)
      await CaptainLocationService.start(_captainId);
    } else {
      // Going offline: stop background service and tell server / disconnect
      await CaptainLocationService.stop();
      // tell server we are offline if needed
      CaptainSocket.socket?.emit("captain:leave", {"captainId": _captainId});
      CaptainSocket.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialCamera = CameraPosition(
      target: _lastPosition ?? const LatLng(28.6139, 77.2090), // default Delhi
      zoom: 15,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Captain Home")),
      body: Column(
        children: [
          SwitchListTile(
            value: _online,
            onChanged: (v) => toggleOnline(v),
            title: const Text("Go Online"),
            subtitle: Text(_online ? "You are visible to riders" : "You are offline"),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: initialCamera,
              onMapCreated: (controller) => _mapController = controller,
              markers: _captainMarker != null ? {_captainMarker!} : {},
              myLocationEnabled: true,
              compassEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Icon(Icons.gps_fixed),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _lastPosition != null
                        ? "Lat: ${_lastPosition!.latitude.toStringAsFixed(6)}, Lng: ${_lastPosition!.longitude.toStringAsFixed(6)}"
                        : "Waiting for GPS...",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
