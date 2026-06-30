import 'dart:async';
import 'package:roofscout/core/constants/api_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OwnerService {
  static const String baseUrl = '${ApiConfig.baseUrl}/owners';

  static Future<Map<String, dynamic>> registrationOwner(
    String name,
    String email,
    String phone,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"full_name": name, "email": email, "phone": phone}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "message": data["message"] ?? "Owner registration suceessfully",
          "data": data["data"],
        };
      } else if (response.statusCode == 409) {
        // Owner already exists - user can still login
        return {
          "success": true,
          "message": "Owner number already registered",
          "data":
              data["data"] ??
              {"full_name": name, "email": email, "phone": phone},
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Failed to register Owner",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Network error: ${e.toString()}"};
    }
  }

  static Future<Map<String, dynamic>> getOwnerData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        return {"success": false, "message": "No token found"};
      }

      final response = await http.get(
        Uri.parse("$baseUrl/me"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "data": data["data"],
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Failed to fetch Owner data",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Network error: ${e.toString()}"};
    }
  }
}
