import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roofscout/core/constants/api_config.dart';

class SavedPropertyService {
  static const String baseUrl = '${ApiConfig.baseUrl}/saved-properties';

  // Save a property
  static Future<Map<String, dynamic>> saveProperty(int userId, int propertyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': userId,
          'property_id': propertyId,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Unsave a property
  static Future<Map<String, dynamic>> unsaveProperty(int userId, int propertyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.delete(
        Uri.parse('$baseUrl/$userId/$propertyId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Get all saved properties for a user
  static Future<Map<String, dynamic>> getSavedProperties(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Check if a property is saved by a user
  static Future<Map<String, dynamic>> checkIfSaved(int userId, int propertyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse('$baseUrl/check/$userId/$propertyId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
