import 'dart:convert';
import 'package:roofscout/core/constants/api_config.dart';
import 'package:http/http.dart' as http;

class UserService {
  static const String baseUrl = '${ApiConfig.baseUrl}/users';

  /// Get user by ID
  static Future<Map<String, dynamic>> getUserProfile(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/$userId"),
        headers: {"Content-Type": "application/json"},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "data": data["data"]};
      } else {
        String msg = data["message"] ?? "Failed to fetch profile";
        if (data["errors"] != null && data["errors"] is List && data["errors"].isNotEmpty) {
          msg = data["errors"][0]["msg"];
        }
        return {"success": false, "message": msg};
      }
    } catch (e) {
      return {"success": false, "message": "Network error: ${e.toString()}"};
    }
  }

  /// POST - Register/Complete Profile
  static Future<Map<String, dynamic>> registerProfile(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "message": data["message"], "data": data["data"]};
      } else {
        String msg = data["message"] ?? "Failed to register profile";
        if (data["errors"] != null && data["errors"] is List && data["errors"].isNotEmpty) {
          msg = data["errors"][0]["msg"];
        }
        return {"success": false, "message": msg};
      }
    } catch (e) {
      return {"success": false, "message": "Network error: ${e.toString()}"};
    }
  }

  /// PUT - Update Profile
  static Future<Map<String, dynamic>> updateProfile(int userId, Map<String, dynamic> userData) async {
    try {
      var request = http.MultipartRequest('PUT', Uri.parse("$baseUrl/$userId"));
      
      // Add text fields
      userData.forEach((key, value) {
        if (key != 'profile_picture' && value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Handle profile picture if it's a local file path
      if (userData['profile_picture'] != null && 
          !userData['profile_picture'].toString().startsWith('http')) {
        request.files.add(await http.MultipartFile.fromPath('profile_picture', userData['profile_picture']));
      } else if (userData['profile_picture'] != null) {
        // If it's already a URL, send it as a field
        request.fields['profile_picture'] = userData['profile_picture'];
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "message": data["message"], "data": data["data"]};
      } else {
        String msg = data["message"] ?? "Failed to update profile";
        if (data["errors"] != null && data["errors"] is List && data["errors"].isNotEmpty) {
          msg = data["errors"][0]["msg"];
        }
        return {"success": false, "message": msg};
      }
    } catch (e) {
      return {"success": false, "message": "Network error: ${e.toString()}"};
    }
  }
}
