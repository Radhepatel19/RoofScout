import 'dart:convert';
import 'package:roofscout/core/constants/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OtpService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<Map<String, dynamic>> sendOtp(String phone) async {
    print("🔹 OtpService: Sending OTP to $phone");
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/otp/send"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone}),
      );

      print("🔹 OtpService: Response Status: ${response.statusCode}");
      print("🔹 OtpService: Response Body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "message": data["message"] ?? "OTP sent"};
      }

      return {
        "success": false,
        "message": data["message"] ?? "Failed to send OTP",
      };
    } catch (e) {
      print("🔴 OtpService Error: $e");
      return {"success": false, "message": "Network error: $e"};
    }
  }

  /// VERIFY OTP + SAVE TOKEN
  static Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/otp/verify"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone, "otp": otp}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["token"]);
        await prefs.setString("user_role", role);
        if (data.containsKey("user_id")) {
          await prefs.setInt("user_id", data["user_id"]);
        }

        return {"success": true};
      }

      return {"success": false, "message": data["message"] ?? "Invalid OTP"};
    } catch (e) {
      return {"success": false, "message": "Network error"};
    }
  }
}
