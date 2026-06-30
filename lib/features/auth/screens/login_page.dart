import 'dart:async';
import 'package:flutter/material.dart';
import 'package:roofscout/features/home/screens/select_city_page.dart';
import 'package:roofscout/features/auth/services/phone_service.dart';
import 'package:roofscout/core/widgets/otp_bottom_sheet.dart';
import 'package:roofscout/features/auth/services/otp_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final phone = _phoneController.text.trim();

    // Validate phone number
    if (phone.isEmpty || phone.length != 10) {
      _showErrorSnackBar("Enter a valid 10-digit phone number");
      return;
    }

    setState(() => _isLoading = true);
    // 1️⃣ Optional: register/login phone first
    final phoneResult = await PhoneService.registerPhone(phone);
    if (!phoneResult["success"]) {
      setState(() => _isLoading = false);
      _showErrorDialog("Authentication Failed", phoneResult["message"]);
      return;
    }

    // Send OTP using OtpService
    final result = await OtpService.sendOtp(phone);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result["success"]) {
      // Show OTP bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => OtpBottomSheet(
          phone: phone,
          onVerify: (String otp) async {
            // Call backend to verify OTP
            final result = await OtpService.verifyOtp(
              phone: phone,
              otp: otp,
              role: "user",
            );

            if (result["success"]) {
              // OTP verified → call onSuccess callback
              Navigator.pop(context); // close bottom sheet
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SelectCityPage()),
              );
            }
            return result; // Return result to BottomSheet for error handling
          },
        ),
      );
    } else {
      _showErrorDialog("OTP Send Failed", result["message"] ?? "Failed to send OTP");
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showErrorDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 15),
            const Divider(),
            const SizedBox(height: 5),
            const Text(
              "Troubleshooting Tip:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              "The application is attempting to reach the backend at:\n${PhoneService.baseUrl}\n\n1. Ensure your backend server is active (node server.js).\n2. Verify that your device or emulator is connected to the same local network as the host IP.",
              style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/roof_scout.png',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Welcome Back!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Login with your phone number to continue",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone),
                    hintText: 'Enter your phone number',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            "Login",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Need help?",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
