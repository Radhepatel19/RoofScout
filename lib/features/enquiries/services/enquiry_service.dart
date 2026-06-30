import 'dart:convert';
import 'package:roofscout/core/constants/api_config.dart';
import 'package:http/http.dart' as http;

class EnquiryService {
  static const String baseUrl = '${ApiConfig.baseUrl}/enquiries';

  static Future<Map<String, dynamic>> sendEnquiry({
    required int propertyId,
    required int userId,
    required String message,
    String? contactPhone,
    String? contactEmail,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'property_id': propertyId,
          'user_id': userId,
          'message': message,
          'contact_phone': contactPhone,
          'contact_email': contactEmail,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getEnquiriesByOwner(int ownerId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/owner/$ownerId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateEnquiryStatus(int enquiryId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$enquiryId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'enquiry_status': status}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
