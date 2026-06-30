import 'dart:convert';
import 'package:roofscout/core/constants/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PropertyService {
  static const String baseUrl = '${ApiConfig.baseUrl}/properties';

  // GET all properties
  static Future<List<Map<String, dynamic>>> getProperties() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception('Failed to load properties');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching properties: $e');
    }
  }

  // Get all Property form owner_id
  static Future<List<Map<String, dynamic>>> getMyProperties() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("User not authenticated");
      }

      // Changed from /owner/me to /owner to match backend route
      final response = await http.get(
        Uri.parse('$baseUrl/owner'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // 🔐
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to load properties');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching properties: $e');
    }
  }

  // POST a new property
  static Future<Map<String, dynamic>> addProperty({
    required String title,
    required String description,
    required String propertyType,
    required String listingType,
    required String state,
    required String city,
    required String fullAddress,
    required double price,
    required double area,
    required int bedrooms,
    required int bathrooms,
    required String furnishing,
    required String furniture,
    required int floorNumber,
    required int totalFloors,
    required String propertyAge,
    required String facing,
    required String availableFrom, // 'YYYY-MM-DD'
    bool isAvailable = false,

    // New fields for unified transaction
    List<String>? images,
    List<String>? amenities,
    Map<String, String>? ownerDocuments,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      throw Exception("User not authenticated");
    }
    try {
      final body = jsonEncode({
        'title': title,
        'description': description,
        'property_type': propertyType,
        'listing_type': listingType,
        'state': state,
        'city': city,
        'full_address': fullAddress,
        'price': price,
        'area': area,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'furnishing': furnishing,
        'furniture': furniture,
        'floor_number': floorNumber,
        'total_floors': totalFloors,
        'property_age': propertyAge,
        'facing': facing,
        'available_from': availableFrom,
        'is_available': isAvailable,

        // Add new fields to body
        'images': images ?? [],
        'amenities': amenities ?? [],
        'ownerDocuments': ownerDocuments,
      });

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
        },
        body: body,
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Map<String, dynamic>.from(data['data']);
        } else {
          throw Exception('Failed to add property');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding property: $e');
    }
  }

  // UPDATE an existing property
  static Future<Map<String, dynamic>> updateProperty({
    required int id, // Property ID is required for update
    required String title,
    required String description,
    required String propertyType,
    required String listingType,
    required String state,
    required String city,
    required String fullAddress,
    required double price,
    required double area,
    required int bedrooms,
    required int bathrooms,
    required String furnishing,
    required String furniture,
    required int floorNumber,
    required int totalFloors,
    required String propertyAge,
    required String facing,
    required String availableFrom, // 'YYYY-MM-DD'
    bool isAvailable = false,

    // New fields for unified transaction
    List<String>? images,
    List<String>? amenities,
    // ownerDocuments are usually not updated during property edit, but can be if needed
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      throw Exception("User not authenticated");
    }
    try {
      final body = jsonEncode({
        'title': title,
        'description': description,
        'property_type': propertyType,
        'listing_type': listingType,
        'state': state,
        'city': city,
        'full_address': fullAddress,
        'price': price,
        'area': area,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'furnishing': furnishing,
        'furniture': furniture,
        'floor_number': floorNumber,
        'total_floors': totalFloors,
        'property_age': propertyAge,
        'facing': facing,
        'available_from': availableFrom,
        'is_available': isAvailable,

        // Add new fields to body
        'images': images ?? [],
        'amenities': amenities ?? [],
      });

      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Map<String, dynamic>.from(data['data']);
        } else {
          throw Exception('Failed to update property');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating property: $e');
    }
  }

  // Update Property Status
  static Future<void> updatePropertyStatus(int propertyId, bool isAvailable) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) throw Exception("User not authenticated");

    final response = await http.put(
      Uri.parse('$baseUrl/$propertyId/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'is_available': isAvailable}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update status');
    }
  }

  // Delete Property
  static Future<void> deleteProperty(int propertyId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) throw Exception("User not authenticated");

    final response = await http.delete(
      Uri.parse('$baseUrl/$propertyId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete property');
    }
  }

  // GET single property by ID
  static Future<Map<String, dynamic>> getPropertyById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Map<String, dynamic>.from(data['data']);
        } else {
          throw Exception('Failed to load property');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching property details: $e');
    }
  }

  // POST a review for a property
  static Future<Map<String, dynamic>> postReview(int propertyId, int rating, String reviewText) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final userId = prefs.getInt("user_id") ?? 1;

      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse('$baseUrl/$propertyId/reviews'),
        headers: headers,
        body: jsonEncode({
          'rating': rating,
          'review_text': reviewText,
          'user_id': userId,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to post review'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // GET reviews for a property
  static Future<List<Map<String, dynamic>>> getPropertyReviews(int propertyId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$propertyId/reviews'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

