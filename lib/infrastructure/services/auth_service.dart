import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // ──────────────────────────────────────────────
  // Google Sign-In via Supabase OAuth
  // ──────────────────────────────────────────────
  Future<bool> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        // On Android/iOS use a deep-link scheme; on web Supabase handles it.
        redirectTo: kIsWeb ? null : 'io.supabase.serviceapp://login-callback/',
      );
      // Returns true immediately to indicate the OAuth flow was launched.
      // The actual session is set when the deep-link returns — at that point
      // onAuthStateChange emits and GoRouter re-evaluates the redirect guard.
      return true;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return false;
    }
  }

  // ──────────────────────────────────────────────
  // Phone OTP – Send
  // Returns the phone number on success (used as the key to verifyOtp).
  // ──────────────────────────────────────────────
  Future<String?> sendOtp(String phoneNumber) async {
    try {
      await _client.auth.signInWithOtp(phone: phoneNumber);
      return phoneNumber; // forwarded to verifyOtp as the "phone" token
    } catch (e) {
      debugPrint('Send OTP Error: $e');
      return null;
    }
  }

  // ──────────────────────────────────────────────
  // Phone OTP – Verify
  // On success, Supabase sets a real session → authStateProvider emits
  // → GoRouter redirect guard fires → user lands on /home automatically.
  // ──────────────────────────────────────────────
 Future<bool> verifyOtp(String phone, String otp) async {
  // 🔥 MOCK OTP (interview purpose)
  if (otp == "123456") return true;
  return false;
}


  // ──────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────
  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => currentSession != null;

  Future<void> signOut() async => _client.auth.signOut();
}
