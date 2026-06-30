import 'dart:convert';
import 'package:roofscout/core/constants/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PropertyFilterService {
  static const String baseUrl = '${ApiConfig.baseUrl}/property-filters';

  /// Save a property filter
  static Future<Map<String, dynamic>> saveFilter({
    required String city,
    required String availableFor,
    required int minBudget,
    required int maxBudget,
    required int bedrooms,
    required String propertyType,
    required String furnishingStatus,
    String? postedBy,
    int? minAreaSqft,
    String? availableFrom,
    int? bathrooms,
    List<String>? amenities,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        return {"success": false, "message": "User not authenticated"};
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "city": city,
          "available_for": availableFor,
          "min_budget": minBudget,
          "max_budget": maxBudget,
          "bedrooms": bedrooms,
          "property_type": propertyType,
          "furnishing_status": furnishingStatus,
          "posted_by": postedBy,
          "min_area_sqft": minAreaSqft,
          "available_from": availableFrom,
          "bathrooms": bathrooms,
          "amenities": amenities ?? [],
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          "success": true,
          "data": data["data"],
        };
      }

      return {
        "success": false,
        "message": data["message"] ?? "Failed to save filter",
      };
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  /// Get saved filters for user
  static Future<Map<String, dynamic>> getUserFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        return {"success": false, "message": "User not authenticated"};
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "data": data["data"] ?? [],
        };
      }

      return {
        "success": false,
        "message": data["message"] ?? "Failed to fetch filters",
      };
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }
}
