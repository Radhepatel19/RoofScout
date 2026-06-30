import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'common_widgets.dart';

class Step3Verification extends StatelessWidget {
  final TextEditingController contactNameController;
  final TextEditingController contactPhoneController;
  final TextEditingController contactEmailController;

  final XFile? aadhaarFront;
  final XFile? aadhaarBack;
  final XFile? panFront;

  final VoidCallback onPickAadhaarFront;
  final VoidCallback onPickAadhaarBack;
  final VoidCallback onPickPanFront;

  const Step3Verification({
    super.key,
    required this.contactNameController,
    required this.contactPhoneController,
    required this.contactEmailController,
    this.aadhaarFront,
    this.aadhaarBack,
    this.panFront,
    required this.onPickAadhaarFront,
    required this.onPickAadhaarBack,
    required this.onPickPanFront,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Owner Verification",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),

          SizedBox(height: 8),

          Text(
            "Verify your identity to list the property",
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),

          SizedBox(height: 24),

          // Contact Information
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                PropertyCommonWidgets.buildInputField(
                  "Contact Person Name",
                  contactNameController,
                  "Owner/Authorized Person",
                  Icons.person_outline_rounded,
                ),

                SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: PropertyCommonWidgets.buildInputField(
                        "Phone Number",
                        contactPhoneController,
                        "10-digit mobile number",
                        Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                      ),
                    ),

                    SizedBox(width: 16),

                    Expanded(
                      child: PropertyCommonWidgets.buildInputField(
                        "Email Address",
                        contactEmailController,
                        "Contact email",
                        Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Aadhaar Verification
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.badge_rounded, color: Color(0xFF0066FF)),
                    SizedBox(width: 12),
                    Text(
                      "Aadhaar Card Verification",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                Text(
                  "Upload clear photos of front and back of your Aadhaar card",
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),

                SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _buildUploadSlot(
                        "Aadhaar Front",
                        aadhaarFront,
                        onPickAadhaarFront,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildUploadSlot(
                        "Aadhaar Back",
                        aadhaarBack,
                        onPickAadhaarBack,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // PAN Verification
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.assignment_rounded, color: Color(0xFF0066FF)),
                    SizedBox(width: 12),
                    Text(
                      "PAN Card Verification",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                Text(
                  "Upload clear photo of your PAN card",
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),

                SizedBox(height: 20),

                _buildUploadSlot(
                  "PAN Card Front",
                  panFront,
                  onPickPanFront,
                  isFullWidth: true,
                ),

                SizedBox(height: 24),

                // Terms and Conditions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Your documents will be verified within 24-48 hours. "
                        "We ensure complete privacy and security of your data.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildUploadSlot(String label, XFile? image, VoidCallback onTap, {bool isFullWidth = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: isFullWidth ? 140 : 100,
            decoration: BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: image == null ? Color(0xFFE2E8F0) : Color(0xFF10B981),
                width: 2,
              ),
              image: image != null
                  ? DecorationImage(
                      image: FileImage(File(image.path)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: image == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_rounded,
                        size: 28,
                        color: Color(0xFF94A3B8),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Upload",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
