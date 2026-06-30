import 'dart:convert';
import 'package:roofscout/core/constants/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PhoneService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// Register or login user by phone
  static Future<Map<String, dynamic>> registerPhone(String phone) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/phone"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save token if returned (optional)
        if (data.containsKey("token")) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);
        }

        return {
          "success": true,
          "message": data["message"] ?? "Phone registered",
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Failed to register",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Network error: ${e.toString()}"};
    }
  }
}
