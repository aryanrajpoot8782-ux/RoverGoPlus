import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class DirectionsApi {
  static const String apiKey = "YOUR_GOOGLE_MAPS_KEY";

  static Future<String> getRoutePolyline(LatLng origin, LatLng destination) async {
    final url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey";

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    if (data["routes"] == null || data["routes"].isEmpty) return "";

    // Return encoded polyline string
    return data["routes"][0]["overview_polyline"]["points"] ?? "";
  }
}
