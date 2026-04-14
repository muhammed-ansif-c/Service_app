import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:service_app/core/router/app_router.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

 await Supabase.initialize(
  url: 'https://mkoxtvtiebhrygrwueyn.supabase.co',
  anonKey: 'sb_publishable_d8ci3Dkw-T-LXdGQDrFMBw_bH9ARMx8',
);

  runApp(const ProviderScope(child: MyApp()));
}

// MyApp must be a ConsumerWidget so it can read appRouterProvider via ref.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read the router from the provider — this is what wires
    // Riverpod auth state → GoRouter refresh → redirect guard.
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Service App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      routerConfig: router,
    );
  }
}
