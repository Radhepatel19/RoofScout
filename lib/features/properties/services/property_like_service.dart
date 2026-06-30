import 'dart:convert';
import 'package:roofscout/core/constants/api_config.dart';
import 'package:http/http.dart' as http;

class PropertyLikeService {
  static const String baseUrl = '${ApiConfig.baseUrl}/property-likes';

  /// Like a property
  static Future<Map<String, dynamic>> likeProperty({
    required int propertyId,
    required int userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "property_id": propertyId,
          "user_id": userId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          "success": true,
          "message": data["message"] ?? "Property liked successfully",
          "data": data["data"],
        };
      } else if (response.statusCode == 409) {
        return {
          "success": true,
          "message": "Already liked",
          "data": data["data"],
        };
      }

      return {
        "success": false,
        "message": data["message"] ?? "Failed to like property",
      };
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  /// Unlike a property
  static Future<Map<String, dynamic>> unlikeProperty({
    required int propertyId,
    required int userId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/$propertyId/$userId"),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": data["message"] ?? "Property unliked successfully",
        };
      }

      return {
        "success": false,
        "message": data["message"] ?? "Failed to unlike property",
      };
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  /// Check if user liked a property
  static Future<Map<String, dynamic>> checkLikeStatus({
    required int propertyId,
    required int userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/check/$propertyId/$userId"),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "is_liked": data["is_liked"] ?? false,
          "data": data["data"],
        };
      }

      return {
        "success": false,
        "message": data["message"] ?? "Failed to check like status",
      };
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  /// Get properties liked by user
  static Future<Map<String, dynamic>> getUserLikes(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/user/$userId"),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "count": data["count"] ?? 0,
          "data": data["data"] ?? [],
        };
      }

      return {
        "success": false,
        "message": data["message"] ?? "Failed to fetch user likes",
      };
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  /// Get total likes for a property
  static Future<Map<String, dynamic>> getPropertyLikes(int propertyId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/property/$propertyId"),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "count": data["count"] ?? 0,
          "data": data["data"] ?? [],
        };
      }

      return {
        "success": false,
        "message": data["message"] ?? "Failed to fetch property likes",
      };
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }
}
