import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../socket/captain_socket.dart';

class CaptainLocationService {
  static bool _running = false;
  static String? _captainId;
  static StreamSubscription<Position>? _positionSub;

  static Future<void> start(String captainId) async {
    if (_running) return;
    _captainId = captainId;
    await _requestPermissions();
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10,
      ),
    ).listen((Position pos) {
      if (_captainId != null) {
        CaptainSocket.sendLiveLocation(
          _captainId!,
          pos.latitude,
          pos.longitude,
        );
      }
    });
    _running = true;
  }

  static Future<void> stop() async {
    if (!_running) return;
    await _positionSub?.cancel();
    _positionSub = null;
    _running = false;
    _captainId = null;
  }

  static Future<void> _requestPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    // Optionally handle deniedForever here
  }

  static Future<void> setAvailability(bool online, String captainId) async {
    if (online) {
      await start(captainId);
    } else {
      await stop();
    }
  }
}
