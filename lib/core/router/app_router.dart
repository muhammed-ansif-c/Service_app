import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:service_app/presentation/screens/booking_success_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:service_app/application/providers/auth_provider.dart';
import 'package:service_app/core/router/app_routes.dart';
import 'package:service_app/presentation/screens/login_screen.dart';
import 'package:service_app/presentation/screens/phone_screen.dart';
import 'package:service_app/presentation/screens/otp_screen.dart';
import 'package:service_app/presentation/screens/home_screen.dart';
import 'package:service_app/presentation/screens/service_listing_screen.dart';
import 'package:service_app/presentation/screens/cart_screen.dart';
import 'package:service_app/presentation/screens/profile_screen.dart';

// Routes that do NOT require a session
const _publicRoutes = [
  AppRoutes.login,
  AppRoutes.phone,
  AppRoutes.otp,
];

// ──────────────────────────────────────────────────────────────────────────
// GoRouter lives inside a Riverpod Provider so it can:
//   1. Read the authStateProvider stream
//   2. Re-evaluate redirect() whenever auth state changes
// ──────────────────────────────────────────────────────────────────────────
final appRouterProvider = Provider<GoRouter>((ref) {
  // A ValueNotifier that GoRouter uses as a "refresh signal".
  // We poke it every time the Supabase auth stream emits a new event.
  final authNotifier = _AuthChangeNotifier();

  // Subscribe to the Supabase auth stream and notify GoRouter on each change.
  ref.listen(authStateProvider, (_, _) => authNotifier.notify());

  final router = GoRouter(
    initialLocation: AppRoutes.login,
  
    refreshListenable: authNotifier,

    // ── Redirect guard ────────────────────────────────────────────────────
    redirect: (BuildContext context, GoRouterState state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final isPublicRoute = _publicRoutes.contains(state.matchedLocation);

      // Not logged in → send to login (unless already on a public route)
      if (!isLoggedIn && !isPublicRoute) return AppRoutes.login;

      // Already logged in → don't stay on login/phone/otp
      if (isLoggedIn && isPublicRoute) return AppRoutes.home;

      // No redirect needed
      return null;
    },

  

    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.phone,
        builder: (context, state) => const PhoneScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) => const OtpScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.services,
        builder: (context, state) => const ServiceListingScreen(),
      ),
      GoRoute(
        path: AppRoutes.cart,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),

      GoRoute(
  path: AppRoutes.bookingSuccess,
  builder: (context, state) => const BookingSuccessScreen(),
),
    ],
  );

  // Dispose the notifier when the provider is disposed
  ref.onDispose(authNotifier.dispose);

  return router;
});

// ──────────────────────────────────────────────────────────────────────────
// Thin ChangeNotifier that GoRouter uses as a refresh listenable.
// Call notify() to make GoRouter re-run its redirect callback.
// ──────────────────────────────────────────────────────────────────────────
class _AuthChangeNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

// appRouter removed — use appRouterProvider via ref.watch(appRouterProvider).
