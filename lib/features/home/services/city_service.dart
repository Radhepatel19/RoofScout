import 'dart:convert';
import 'package:roofscout/core/constants/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CityService {
  static const String baseUrl = '${ApiConfig.baseUrl}/city';

  // Get My cities from backend
  static Future<String?> getMyCity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null || token.isEmpty) {
        return null;
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data["data"] != null && data["data"]["city"] != null) {
           return data["data"]["city"];
        }
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<http.Response> updateCity(String cityName, String state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception("User not logged in");
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "city": "$cityName,$state", // store like "Surat,Gujarat"
        }),
      );

      return response;
    } catch (e) {
      throw Exception("Failed to update city: $e");
    }
  }
}
