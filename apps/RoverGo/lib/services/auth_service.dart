
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
	static const String _baseUrl = 'http://localhost:4000/api/auth';

	static Future<String?> register({required String name, required String phone, required String password}) async {
		final res = await http.post(
			Uri.parse('$_baseUrl/register'),
			headers: {'Content-Type': 'application/json'},
			body: jsonEncode({'name': name, 'phone': phone, 'password': password}),
		);
		if (res.statusCode == 201) return null;
		return jsonDecode(res.body)['message'] ?? 'Registration failed';
	}

	static Future<String?> login({required String phone, required String password}) async {
		final res = await http.post(
			Uri.parse('$_baseUrl/login'),
			headers: {'Content-Type': 'application/json'},
			body: jsonEncode({'phone': phone, 'password': password}),
		);
		if (res.statusCode == 200) {
			final token = jsonDecode(res.body)['token'];
			final prefs = await SharedPreferences.getInstance();
			await prefs.setString('jwt', token);
			return null;
		}
		return jsonDecode(res.body)['message'] ?? 'Login failed';
	}

	static Future<void> logout() async {
		final prefs = await SharedPreferences.getInstance();
		await prefs.remove('jwt');
	}

	static Future<String?> getToken() async {
		final prefs = await SharedPreferences.getInstance();
		return prefs.getString('jwt');
	}
}
