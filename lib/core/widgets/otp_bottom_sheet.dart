import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roofscout/features/auth/services/otp_service.dart';

class OtpBottomSheet extends StatefulWidget {
  final String phone;
  final Future<Map<String, dynamic>> Function(String otp) onVerify; // send OTP to parent

  const OtpBottomSheet({
    super.key,
    required this.phone,
    required this.onVerify,
  });

  @override
  State<OtpBottomSheet> createState() => _OtpBottomSheetState();
}

class _OtpBottomSheetState extends State<OtpBottomSheet> {
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());
  final List<String> _previousValues = List.generate(6, (_) => "");
  int _start = 30;
  bool _isResendEnabled = false;
  String _sendButtonText = "Verify OTP";

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _start = 30;
      _isResendEnabled = false;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_start == 0) {
        setState(() => _isResendEnabled = true);
        return false;
      } else {
        setState(() => _start--);
        return true;
      }
    });
  }

  /// Resend OTP
  Future<void> _resendOtp() async {
    setState(() => _sendButtonText = "Sending...");
    final result = await OtpService.sendOtp(widget.phone);
    if (result["success"]) {
      _startTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"]),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() => _sendButtonText = "Verify OTP");
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Text(
                "Verify Phone Number",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "We sent a verification code to ${widget.phone}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              /// OTP Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                      (index) => SizedBox(
                    width: 48,
                    height: 60,
                    child: TextField(
                      controller: _otpControllers[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      onChanged: (value) {
                        if (_previousValues[index].isEmpty &&
                            value.isNotEmpty &&
                            index < 5) {
                          FocusScope.of(context).nextFocus();
                        }
                        if (value.isEmpty && index > 0) {
                          FocusScope.of(context).previousFocus();
                        }
                        _previousValues[index] = value;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              /// Resend OTP
              Center(
                child: TextButton(
                  onPressed: _isResendEnabled ? _resendOtp : null,
                  child: Text(
                    _isResendEnabled
                        ? "Resend OTP"
                        : "Resend OTP in $_start s",
                    style: TextStyle(
                      color:
                      _isResendEnabled ? Colors.blueAccent : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              /// Verify Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() => _sendButtonText = "Verifying...");
                    String otp = _otpControllers.map((c) => c.text).join();
                    
                    final result = await widget.onVerify(otp); // send OTP to parent
                    
                    if (!mounted) return;

                    if (!result["success"]) {
                      // Show error inside the sheet context
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result["message"] ?? "Invalid OTP"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      setState(() => _sendButtonText = "Verify OTP");
                    }
                    // On success, parent handles navigation, so we don't need to do anything here.
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _sendButtonText,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
