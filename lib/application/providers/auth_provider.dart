import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../infrastructure/services/auth_service.dart';

// ──────────────────────────────────────────────
// Low-level service provider
// ──────────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ──────────────────────────────────────────────
// Stream of Supabase auth state changes
// Useful for GoRouter redirect logic later.
// ──────────────────────────────────────────────
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

// ──────────────────────────────────────────────
// AuthNotifier – exposes methods to UI screens
// ──────────────────────────────────────────────
final authProvider = Provider<AuthNotifier>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

class AuthNotifier {
  final AuthService _authService;

  AuthNotifier(this._authService);

  Future<bool> signInWithGoogle() => _authService.signInWithGoogle();

  Future<String?> sendOtp(String phoneNumber) =>
      _authService.sendOtp(phoneNumber);

  Future<bool> verifyOtp(String phone, String otp) =>
      _authService.verifyOtp(phone, otp);

  bool get isLoggedIn => _authService.isLoggedIn;

  Future<void> signOut() => _authService.signOut();
}
