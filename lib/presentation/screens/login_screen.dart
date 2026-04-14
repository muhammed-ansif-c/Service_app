import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _googleLoading = false;

  @override
  Widget build(BuildContext context) {
    const Color brandGreen = Color(0xFF59C271);
    const Color lightGrey = Color(0xFFF0F0F0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 3),

              // Central Logo Placeholder
              Container(
                width: 160,
                height: 85,
                decoration: const BoxDecoration(color: brandGreen),
                alignment: Alignment.center,
                child: const Text(
                  'Logo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Spacer(flex: 4),

              // ── Google Sign-In Button ────────────────────────────────────
              // KEY FIX: do NOT call context.go('/home') here.
              // signInWithGoogle() opens the browser. When the deep-link
              // returns, Supabase sets the session, authStateProvider emits
              // a new event, GoRouter's refreshListenable fires, and the
              // redirect() guard automatically sends the user to /home.
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _googleLoading
                      ? null
                      : () async {
                          setState(() => _googleLoading = true);
                          await ref.read(authProvider).signInWithGoogle();
                          // Do NOT navigate here — router redirect handles it.
                          if (mounted) setState(() => _googleLoading = false);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightGrey,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _googleLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                              height: 20,
                              errorBuilder: (_, _, _) =>
                                  const Icon(Icons.account_circle, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 14),

              // ── Phone / OTP Button ───────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => context.go('/otp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Phone',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}