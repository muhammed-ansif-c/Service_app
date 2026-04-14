import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:service_app/application/providers/service_provider.dart';
import 'package:service_app/core/router/app_routes.dart';
import 'package:service_app/domain/models/service_item.dart';




class ServiceListingScreen extends ConsumerWidget {
  const ServiceListingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(servicesListProvider);
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final totalQty = cartNotifier.totalItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          Column(
            children: [
              _buildAppBar(context),
              _buildCategoryTabs(ref),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    return _buildServiceCard(services[index], ref);
                  },
                ),
              ),
            ],
          ),
          // Bottom Cart Bar (Visible only if items > 0)
          if (totalQty > 0)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
           child: _buildBottomCartBar(
  context,
  totalQty,
  cartNotifier.totalPrice(services),
),
            ),
        ],
      ),
    );
  }

  // 1. Custom App Bar
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      color: Colors.white,
      child: Row(
        children: [
         GestureDetector(
  onTap: () {
    context.go(AppRoutes.home);
  },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.chevron_left, size: 24),
            ),
          ),
          const SizedBox(width: 20),
          const Text(
            "Cleaning Services",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // 2. Horizontal Category Tabs
  Widget _buildCategoryTabs(WidgetRef ref) {
    final categories = ["Deep cleaning", "Maid Services", "Car Cleaning", "Carpet Cleaning"];
    final selected = ref.watch(categoryProvider);

    return Container(
      height: 60,
      width: double.infinity,
      color: const Color(0xFFE0FBEF), // Very light mint green
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = categories[index] == selected;
          return GestureDetector(
            onTap: () => ref.read(categoryProvider.notifier).state = categories[index],
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2EAD6F) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 3. Service Card (Includes Image, Info, and Add/Stepper)
  Widget _buildServiceCard(ServiceItem item, WidgetRef ref) {
    final qty = ref.watch(cartProvider)[item.id] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              item.imageUrl,
              height: 90,
              width: 90,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "(${item.rating}) ${item.orders}",
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  item.duration,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  "₹ ${item.price.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ],
            ),
          ),
          // Action Button Area
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 50),
              qty == 0 ? _buildAddButton(ref, item.id) : _buildStepper(ref, item.id, qty),
            ],
          )
        ],
      ),
    );
  }

  // Initial State: ADD button
  Widget _buildAddButton(WidgetRef ref, String id) {
    return GestureDetector(
      onTap: () => ref.read(cartProvider.notifier).addItem(id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF5CC28D),
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [Color(0xFF67D49E), Color(0xFF2EAD6F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Text(
          "Add  +",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  // Active State: Stepper [- 1 +]
  Widget _buildStepper(WidgetRef ref, String id, int qty) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => ref.read(cartProvider.notifier).removeItem(id),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text("-", style: TextStyle(fontSize: 20, color: Color(0xFF2EAD6F), fontWeight: FontWeight.bold)),
            ),
          ),
          Text(
            "$qty",
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2EAD6F)),
          ),
          GestureDetector(
            onTap: () => ref.read(cartProvider.notifier).addItem(id),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text("+", style: TextStyle(fontSize: 18, color: Color(0xFF2EAD6F), fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Sticky Bottom Cart Bar
Widget _buildBottomCartBar(BuildContext context, int count, double total) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "$count items  |  ₹ ${total.toStringAsFixed(0)}",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black54),
            ),
          ),
         GestureDetector(
  onTap: () {
    context.push(AppRoutes.cart);
  },
  child: Container(
    width: double.infinity,
    height: 55,
    decoration: BoxDecoration(
      color: const Color(0xFFFF7043),
      borderRadius: BorderRadius.circular(15),
    ),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "VIEW CART",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
        SizedBox(width: 10),
        Icon(Icons.play_arrow, color: Colors.white, size: 16),
      ],
    ),
  ),
)
        ],
      ),
    );
  }
}