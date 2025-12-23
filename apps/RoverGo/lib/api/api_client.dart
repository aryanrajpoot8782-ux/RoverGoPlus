import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = "http://10.0.2.2:4000/api";
  static String? token;

  /* ------------------------------------------------------------
    LOGIN
  ------------------------------------------------------------ */
  static Future<dynamic> login(String phone, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone": phone, "password": password}),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data["token"] != null) {
      token = data["token"]; // Save JWT
    }

    return data;
  }

  /* ------------------------------------------------------------
    REGISTER
  ------------------------------------------------------------ */
  static Future<dynamic> register(
      String name, String phone, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "phone": phone,
        "password": password,
      }),
    );

    return jsonDecode(res.body);
  }

  /* ------------------------------------------------------------
    GET PROFILE (requires token)
  ------------------------------------------------------------ */
  static Future<dynamic> getProfile() async {
    final res = await http.get(
      Uri.parse("$baseUrl/users/me"),
      headers: {"Authorization": "Bearer $token"},
    );

    return jsonDecode(res.body);
  }

  /* ------------------------------------------------------------
    GET ONLINE CAPTAINS
  ------------------------------------------------------------ */
  static Future<dynamic> getOnlineCaptains() async {
    final res = await http.get(
      Uri.parse("$baseUrl/captains/online"),
      headers: {"Authorization": "Bearer $token"},
    );

    return jsonDecode(res.body);
  }

  /* ------------------------------------------------------------
    LOGOUT
  ------------------------------------------------------------ */
  static Future<void> logout() async {
    token = null;
  }

  /* ------------------------------------------------------------
    REQUEST RIDE
  ------------------------------------------------------------ */
  static Future<dynamic> requestRide({
    required String pickup,
    required String dropoff,
    required double distanceKm,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/rides/request"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "pickup": pickup,
        "dropoff": dropoff,
        "distanceKm": distanceKm,
      }),
    );

    return jsonDecode(res.body);
  }
}

