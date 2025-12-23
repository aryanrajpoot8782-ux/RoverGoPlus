import 'package:shared_preferences/shared_preferences.dart';

class CaptainApi {
  static const String baseUrl = "https://example.com/api";

  // ------------------------------------------------------------
  // 🔐 LOGIN
  // ------------------------------------------------------------
  static Future<Map<String, dynamic>> login(String phone, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Dummy success login response
    return {
      "success": true,
      "captainId": "captain_001",
      "token": "abc123xyz",
    };
  }

  // ------------------------------------------------------------
  // 📝 REGISTER (4 PARAMETERS)
  // ------------------------------------------------------------
  static Future<Map<String, dynamic>> register(
    String name,
    String phone,
    String password,
    String vehicleNo,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Dummy success register response
    return {
      "success": true,
      "captainId": "captain_001",
      "vehicleNo": vehicleNo,
    };
  }

  // ------------------------------------------------------------
  // 💰 EARNINGS
  // ------------------------------------------------------------
  static Future<Map<String, dynamic>> getEarnings(String captainId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return {
      "today": 520,
      "weekly": 3480,
      "monthly": 16500,
    };
  }

  // ------------------------------------------------------------
  // 📜 RIDE HISTORY
  // ------------------------------------------------------------
  static Future<List<Map<String, dynamic>>> fetchRideHistory(
      String captainId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      {
        "id": "ride_001",
        "date": "2025-11-15",
        "pickup": "Airport",
        "drop": "City Center",
        "fare": 250.0,
      },
      {
        "id": "ride_002",
        "date": "2025-11-16",
        "pickup": "Mall",
        "drop": "Station",
        "fare": 180.0,
      },
    ];
  }

  // ------------------------------------------------------------
  // 👤 CAPTAIN PROFILE
  // ------------------------------------------------------------
  static Future<Map<String, dynamic>> fetchCaptainProfile(
      String captainId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return {
      "id": captainId,
      "name": "John Captain",
      "phone": "+91 99999 11111",
      "vehicle": {
        "make": "Toyota",
        "model": "Innova",
        "number": "KA-01-AB-1234",
      }
    };
  }

  // ------------------------------------------------------------
  // 🆔 CAPTAIN ID - GETTER
  // ------------------------------------------------------------
  static Future<String?> get captainId async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("captainId");
  }

  // ------------------------------------------------------------
  // SAVE CAPTAIN ID
  // ------------------------------------------------------------
  static Future<void> saveCaptainId(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("captainId", id);
  }
}
