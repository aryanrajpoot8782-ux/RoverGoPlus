import 'dart:convert';
import 'package:http/http.dart' as http;

class RiderApi {
  static const String base = "http://10.0.2.2:4000/api";
  static String? riderId;
  static String? token;

  static Future requestRide(
    String riderId,
    double pLat,
    double pLng,
    double dLat,
    double dLng,
  ) async {
    final res = await http.post(
      Uri.parse("$base/ride/create"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "riderId": riderId,
        "pickupLat": pLat,
        "pickupLng": pLng,
        "dropLat": dLat,
        "dropLng": dLng,
      }),
    );

    return jsonDecode(res.body);
  }
}
