import 'dart:convert';
import 'package:roofscout/core/constants/api_config.dart';
import 'package:http/http.dart' as http;

class PropertyReportService {
  static const String baseUrl = '${ApiConfig.baseUrl}/property-reports';

  static Future<Map<String, dynamic>> submitReport({
    required int propertyId,
    required int userId,
    required String reportType,
    required String description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'property_id': propertyId,
          'user_id': userId,
          'report_type': reportType,
          'description': description,
          'status': 'pending',
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getReportsByProperty(int propertyId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/property/$propertyId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getReportsByUser(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/user/$userId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
