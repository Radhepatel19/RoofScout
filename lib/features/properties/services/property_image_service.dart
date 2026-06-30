import 'dart:convert';
import 'package:roofscout/core/constants/api_config.dart';
import 'package:http/http.dart' as http;

class PropertyImagesService {
  static const String baseUrl = '${ApiConfig.baseUrl}/property-images';

  /// Upload multiple images for a property from file paths
  static Future<List<Map<String, dynamic>>> addPropertyImagesBatch({
    required int propertyId,
    required List<String> imagePaths,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/batch'));
      
      request.fields['property_id'] = propertyId.toString();

      for (String path in imagePaths) {
        request.files.add(await http.MultipartFile.fromPath('images', path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception('Failed to upload property images: ${data['message']}');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading property images: $e');
    }
  }

  /// Get all images for a property
  static Future<List<Map<String, dynamic>>> getPropertyImages(
    int propertyId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/property/$propertyId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception('Failed to fetch property images');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching property images: $e');
    }
  }

  // Get a single image by image_id
  static Future<Map<String, dynamic>> getImageById(int imageId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$imageId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Map<String, dynamic>.from(data['data']);
        } else {
          throw Exception('Failed to fetch image');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching image: $e');
    }
  }
}
