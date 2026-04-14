import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:service_app/application/providers/auth_provider.dart';
import 'package:service_app/core/router/app_routes.dart';

// Note: Replace this import with your actual auth provider path
// import 'package:service_app/application/providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final TextEditingController _phoneController = TextEditingController();

  // 6 Controllers and FocusNodes for the OTP boxes
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _otpSent = false;
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  // Helper to get full OTP string
  String get _currentOtp => _otpControllers.map((e) => e.text).join();

  Future<void> _handleSendOtp() async {
    if (_phoneController.text.length < 10) {
      setState(() => _errorMessage = "Please enter a valid 10-digit number");
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    // Dummy Delay to simulate API
    await Future.delayed(const Duration(seconds: 2));

    // --- INTEGRATE YOUR RIVERPOD LOGIC HERE ---
    // final phone = '+91${_phoneController.text.trim()}';
    // final result = await ref.read(authProvider).sendOtp(phone);

    setState(() {
      _loading = false;
      _otpSent = true;
    });
  }

  Future<void> _handleVerifyOtp() async {
    if (_currentOtp.length < 6) {
      setState(() => _errorMessage = "Please enter all 6 digits");
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    // Dummy logic as requested (Hardcoded 123456)
    await Future.delayed(const Duration(seconds: 2));
if (_currentOtp == "123456") {
  setState(() => _loading = false);

  ref.read(mockAuthProvider.notifier).state = true; // ✅ mark login

  if (mounted) context.go(AppRoutes.home);
}
    else {
      setState(() {
        _loading = false;
        _errorMessage = "Invalid OTP. Please try 123456";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2EAD6F);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _otpSent
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => setState(() => _otpSent = false),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              _otpSent ? "Verify Details" : "Login",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _otpSent
                  ? "Enter the 6-digit OTP sent to +91 ${_phoneController.text}"
                  : "Enter your phone number to proceed",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),
            const SizedBox(height: 40),

            // --- PHONE INPUT SECTION ---
            AbsorbPointer(
              absorbing: _otpSent, // Disables input when OTP is sent
              child: Opacity(
                opacity: _otpSent ? 0.5 : 1.0, // Blurs UI when OTP is sent
                child: Column(
                  children: [
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 12,
                          ),
                          child: Text(
                            "+91",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        hintText: "00000 00000",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          letterSpacing: 2,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (!_otpSent)
                      _buildButton("Send OTP", _handleSendOtp, primaryGreen),
                  ],
                ),
              ),
            ),

            // --- OTP INPUT SECTION ---
            if (_otpSent) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => _buildOtpBox(index)),
              ),
              const SizedBox(height: 30),
              _buildButton("Verify OTP", _handleVerifyOtp, primaryGreen),
              Center(
                child: TextButton(
                  onPressed: _loading
                      ? null
                      : () => setState(() => _otpSent = false),
                  child: const Text(
                    "Edit Phone Number",
                    style: TextStyle(
                      color: primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],

            // --- ERROR MESSAGE ---
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper: Individual OTP Box
  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 45,
      height: 55,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Colors.grey.shade100,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2EAD6F), width: 2),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  // Helper: Main Action Button
  Widget _buildButton(String label, VoidCallback onPressed, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
