import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:service_app/application/providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String? _phone; // stores the phone used to send OTP
  bool _otpSent = false;
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = '+91${_phoneController.text.trim()}';
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final result = await ref.read(authProvider).sendOtp(phone);

    if (!mounted) return;

    if (result != null) {
      setState(() {
        _phone = result; // result == phone number (Supabase token key)
        _otpSent = true;
        _loading = false;
      });
    } else {
      setState(() {
        _errorMessage = 'Failed to send OTP. Check your number and try again.';
        _loading = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final success = await ref
        .read(authProvider)
        .verifyOtp(_phone!, _otpController.text.trim());

    if (!mounted) return;

    setState(() => _loading = false);

  if (success) {
  context.go('/home'); // 🔥 manual navigation
} else {
  setState(() => _errorMessage = 'Invalid OTP. Please try again.');
}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Phone input ────────────────────────────────────────────────
            if (!_otpSent)
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixText: '+91 ',
                ),
                keyboardType: TextInputType.phone,
              ),

            const SizedBox(height: 20),

            // ── Send OTP ───────────────────────────────────────────────────
            if (!_otpSent)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _sendOtp,
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send OTP'),
                ),
              ),

            // ── OTP input + verify ─────────────────────────────────────────
            if (_otpSent) ...[
              Text(
                'OTP sent to +91${_phoneController.text.trim()}',
                style: const TextStyle(color: Colors.green),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _otpController,
                decoration: const InputDecoration(labelText: 'Enter OTP'),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _verifyOtp,
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Verify OTP'),
                ),
              ),
            ],

            // ── Error display ──────────────────────────────────────────────
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}