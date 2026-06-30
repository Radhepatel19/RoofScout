import 'dart:convert';
import 'package:roofscout/core/constants/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OwnerDocumentsService {
  static const String baseUrl = '${ApiConfig.baseUrl}/owner-documents';

  /// Helper: get auth headers
  static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      throw Exception("User not authenticated");
    }

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // =====================================================
  // POST - Upload / Update Owner Documents from file paths
  // =====================================================
  static Future<Map<String, dynamic>> uploadDocuments({
    required String aadharFrontPath,
    String? aadharBackPath,
    required String panPath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      throw Exception("User not authenticated");
    }

    var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
    
    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(await http.MultipartFile.fromPath('aadhar_image_front', aadharFrontPath));
    request.files.add(await http.MultipartFile.fromPath('pan_image', panPath));

    if (aadharBackPath != null) {
      request.files.add(await http.MultipartFile.fromPath('aadhar_image_back', aadharBackPath));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    return jsonDecode(response.body);
  }

  // =====================================================
  // GET - Logged-in Owner Documents (/me)
  // =====================================================
  static Future<Map<String, dynamic>> getMyDocuments() async {
    final headers = await _authHeaders();

    final response = await http.get(Uri.parse("$baseUrl/me"), headers: headers);

    return jsonDecode(response.body);
  }

  // =====================================================
  // PUT - Update Documents (partial update)
  // =====================================================
  static Future<Map<String, dynamic>> updateDocuments({
    String? aadharFrontUrl,
    String? aadharBackUrl,
    String? panUrl,
    required int documentId,
  }) async {
    final headers = await _authHeaders();

    final Map<String, dynamic> body = {};

    if (aadharFrontUrl != null) {
      body["aadhar_image_front"] = aadharFrontUrl;
    }
    if (aadharBackUrl != null) {
      body["aadhar_image_back"] = aadharBackUrl;
    }
    if (panUrl != null) {
      body["pan_image"] = panUrl;
    }

    final response = await http.put(
      Uri.parse("$baseUrl/$documentId"),
      headers: headers,
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

  // =====================================================
  // ADMIN - Verify / Reject Documents
  // =====================================================
  static Future<Map<String, dynamic>> verifyDocument({
    required int documentId,
    required String status, // pending | verified | rejected
  }) async {
    final headers = await _authHeaders();

    final response = await http.put(
      Uri.parse("$baseUrl/$documentId/verify"),
      headers: headers,
      body: jsonEncode({"verification_status": status}),
    );

    return jsonDecode(response.body);
  }

  // =====================================================
  // ADMIN - Get All Documents
  // =====================================================
  static Future<Map<String, dynamic>> getAllDocuments() async {
    final headers = await _authHeaders();

    final response = await http.get(Uri.parse(baseUrl), headers: headers);

    return jsonDecode(response.body);
  }
}
