import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:service_app/application/providers/service_provider.dart';
import 'package:service_app/core/router/app_routes.dart';

// --- Providers for State Management ---

// Manages the current active tab in the bottom navigation
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

// Provides the list for "Available Services" grid
final availableServicesProvider = Provider<List<Map<String, dynamic>>>(
  (ref) => [
    {'name': 'Cleaning', 'icon': Icons.cleaning_services, 'color': Colors.teal},
    {
      'name': 'Waste Disposal',
      'icon': Icons.delete_outline,
      'color': Colors.green,
    },
    {'name': 'Plumbing', 'icon': Icons.plumbing, 'color': Colors.lightGreen},
    {'name': 'Plumbing', 'icon': Icons.plumbing, 'color': Colors.lightGreen},
    {'name': 'Cleaning', 'icon': Icons.cleaning_services, 'color': Colors.teal},
    {
      'name': 'Waste Disposal',
      'icon': Icons.delete_outline,
      'color': Colors.green,
    },
    {'name': 'Plumbing', 'icon': Icons.plumbing, 'color': Colors.lightGreen},
  ],
);

// --- Main Home Screen ---

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, ref),
              _buildBanner(),
              _buildSearchBar(),
              _buildAvailableServicesSection(),
              _buildCleaningServicesSection(context),
              // const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, ref, navIndex),
    );
  }

  // 1. Header (Location & Cart Badge)
  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("👋", style: TextStyle(fontSize: 20)),
              Row(
                children: const [
                  Text(
                    "406, Skyline Park Dale, MM Road...",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF2EAD6F),
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
          _buildCartBadge(context, ref),
        ],
      ),
    );
  }

  Widget _buildCartBadge(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    int totalQty = 0;
    for (var qty in cart.values) {
      totalQty += qty;
    }

    return GestureDetector(
      onTap: () {
        context.go(AppRoutes.cart);
      },
      child: Stack(
        clipBehavior: Clip.none,

        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              color: Color(0xFF2EAD6F),
            ),
          ),
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),

              child: Text(
                "$totalQty",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Banner Section (Promo Card)
  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/Promo Advertising.png', // 👈 your image name
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildBannerInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(icon, size: 10, color: const Color(0xFF2EAD6F)),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // 3. Search Bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search for a service",
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF2EAD6F),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.search, color: Colors.white),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // 4. Available Services (Grid with dynamic data from Riverpod)
  Widget _buildAvailableServicesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.asset('assets/images/Categories.png', fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildGridItem(Map<String, dynamic> data) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: (data['color'] as Color).withOpacity(0.1),
          child: Icon(
            data['icon'] as IconData,
            color: data['color'] as Color,
            size: 22,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          data['name'],
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSeeAllItem() {
    return Column(
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_forward, color: Color(0xFF2EAD6F)),
        ),
        const SizedBox(height: 8),
        const Text(
          "See All",
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF2EAD6F),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // 5. Cleaning Services Horizontal Scroll
  Widget _buildCleaningServicesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Title Row
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              const Text(
                "Cleaning Services",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              GestureDetector(
                onTap: () {
                  context.go(AppRoutes.services);
                },
                child: const Row(
                  children: [
                    Text(
                      "See All",
                      style: TextStyle(
                        color: Color(0xFF2EAD6F),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Color(0xFF2EAD6F),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 🔹 Horizontal Cards
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            children: [
              _serviceCard('assets/images/cleaning.png', 'Home Cleaning'),
              _serviceCard('assets/images/carpet.png', 'Carpet Cleaning'),
              _serviceCard('assets/images/sofa.png', 'Sofa Cleaning'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _serviceCard(String image, String title) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              image,
              height: 120,
              width: 160,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // 6. Custom Pill-style Bottom Navigation
  Widget _buildBottomNavigationBar(BuildContext context, WidgetRef ref, int currentIndex){
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
         _navItem(context, ref, 0, Icons.home, "Home", currentIndex),
        _navItem(context, ref, 1, Icons.calendar_month_outlined, "Bookings", currentIndex),
        _navItem(context, ref, 2, Icons.person_outline, "Account", currentIndex),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    WidgetRef ref,
    int index,
    IconData icon,
    String label,
    int current,
  ) {
    bool isSelected = index == current;
    return GestureDetector(
      onTap: () {
        ref.read(bottomNavIndexProvider.notifier).state = index;

        if (index == 0) {
          context.go(AppRoutes.home);
        } else if (index == 1) {
          // later  can add bookings screen
        } else if (index == 2) {
          context.go(AppRoutes.profile);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF2EAD6F) : Colors.grey,
            ),
            if (isSelected) const SizedBox(width: 8),
            if (isSelected)
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF2EAD6F),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
