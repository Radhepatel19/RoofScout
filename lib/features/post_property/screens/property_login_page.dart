import 'package:flutter/material.dart';
import 'package:roofscout/features/post_property/screens/property_steps_page.dart';
import 'package:roofscout/features/post_property/services/owner_service.dart';
import 'package:roofscout/features/auth/services/otp_service.dart';
import 'package:roofscout/core/widgets/otp_bottom_sheet.dart';

class PropertyLoginPage extends StatefulWidget {
  const PropertyLoginPage({super.key});

  @override
  State<PropertyLoginPage> createState() => _PropertyLoginPageState();
}

class _PropertyLoginPageState extends State<PropertyLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String selectedRole = "Owner"; // Default role
  bool _isLoading = false;
  String? otps; // Store entered OTP

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleOwnerLogin() async {
    final fullName = _nameController.text;
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      _showErrorSnackBar("Please enter your phone number");
      return;
    }
    if (phone.length < 10) {
      _showErrorSnackBar("Please enter a valid phone number");
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await OwnerService.registrationOwner(
        fullName,
        email,
        phone,
      );

      setState(() {
        _isLoading = false;
      });

      if (result["success"]) {
        // Show success message first
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text(result["message"]),
               backgroundColor: Colors.green,
               duration: const Duration(seconds: 1),
             ),
           );
        }

        // Explicitly send OTP using the service to ensure it shows in terminal
        await OtpService.sendOtp(phone);

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          builder: (context) => OtpBottomSheet(
            phone: phone,
            onVerify: (String otp) async {
              // Store the OTP locally as requested
              setState(() {
                otps = otp;
              });

              // Call backend to verify OTP
              final result = await OtpService.verifyOtp(
                phone: phone,
                otp: otp,
                role: "owner",
              );

              if (result["success"]) {
                // OTP verified → call onSuccess callback
                Navigator.pop(context); // close bottom sheet
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const PropertyStepsPages()),
                );
              }
              return result; // Return result to BottomSheet for error handling
            },
          ),
        );
      } else {
        // Show error message
        _showErrorDialog(
          "Registration Failed",
          result["message"] ?? "Failed to register phone number",
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog("Connection Failure", "An error occurred: ${e.toString()}");
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
              "The application is attempting to reach the backend at:\n${OwnerService.baseUrl}\n\n1. Ensure your backend server is active (node server.js).\n2. Verify that your device or emulator is connected to the same local network as the host IP.",
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text(
          "Register to Sell / Rent",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Fill your details below to continue",
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 20),

              // Name field
              _buildTextField(
                controller: _nameController,
                label: "Full Name",
                icon: Icons.person,
                validator: (value) =>
                    value!.isEmpty ? "Please enter your name" : null,
              ),

              const SizedBox(height: 16),

              // Email field
              _buildTextField(
                controller: _emailController,
                label: "Email Address",
                icon: Icons.email,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your email";
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return "Enter a valid email address";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Phone field
              _buildTextField(
                controller: _phoneController,
                label: "Phone Number",
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.length != 10 ? "Phone number must be exactly 10 digits" : null,
              ),

              const SizedBox(height: 20),

              const Text(
                "Select Role",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  _buildRoleOption("Owner", Icons.home_filled),
                  const SizedBox(width: 16),
                  _buildRoleOption("Broker", Icons.business_center),
                ],
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleOwnerLogin,

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
                          "Continue",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TextField Builder
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(fontSize: 14, color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }

  // Role selection button
  Widget _buildRoleOption(String role, IconData icon) {
    final isSelected = selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedRole = role;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blueAccent : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
              width: 1.5,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.black54),
              const SizedBox(height: 6),
              Text(
                role,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
