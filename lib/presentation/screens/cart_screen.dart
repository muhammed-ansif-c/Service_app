import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:service_app/application/providers/service_provider.dart';
import 'package:service_app/core/router/app_routes.dart';
import 'package:service_app/domain/models/service_item.dart';
// Assuming your files are in these locations, update imports if necessary
// import 'package:service_app/domain/models/service_item.dart';
// import 'package:service_app/presentation/providers/service_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final allServices = ref.watch(servicesListProvider);

    // Filter services that are actually in the cart
    final cartItems = allServices
        .where((item) => cart.containsKey(item.id))
        .toList();

    final cartNotifier = ref.read(cartProvider.notifier);
    final totalAmount = cartNotifier.totalPrice(allServices);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Cart Items List
                    ...cartItems.asMap().entries.map((entry) {
                      int idx = entry.key;
                      var item = entry.value;
                      int qty = cart[item.id] ?? 0;
                      return _buildCartItemRow(idx + 1, item, qty, ref);
                    }),

                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text(
                        "Add more Services",
                        style: TextStyle(
                          color: Color(0xFF2EAD6F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),
                    const Text(
                      "Frequently added services",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // 2. Frequently Added Services (Horizontal)
                    _buildFrequentlyAddedList(allServices, ref),

                    const SizedBox(height: 25),

                    // 3. Coupon Code Section
                    _buildCouponSection(),

                    const SizedBox(height: 20),

                    // 4. Wallet Info
                    _buildWalletInfo(),

                    const SizedBox(height: 20),

                    // 5. Bill Details
                    _buildBillDetails(cartItems, cart, totalAmount),

                    const SizedBox(height: 120), // Padding for sticky bottom
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
     bottomSheet: _buildStickyBottom(context, ref, totalAmount),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          GestureDetector(
          onTap: () {
  context.go(AppRoutes.home);
},
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: const Icon(Icons.chevron_left, size: 24),
            ),
          ),
          const SizedBox(width: 20),
          const Text(
            "Cart",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemRow(
    int index,
    ServiceItem item,
    int qty,
    WidgetRef ref,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(
            "$index. ",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              item.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          // Stepper
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                _stepperBtn(
                  Icons.remove,
                  () => ref.read(cartProvider.notifier).removeItem(item.id),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    "$qty",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                _stepperBtn(
                  Icons.add,
                  () => ref.read(cartProvider.notifier).addItem(item.id),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Text(
            "₹${(item.price * qty).toInt()}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepperBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF616161),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 14, color: Colors.white),
      ),
    );
  }

  Widget _buildFrequentlyAddedList(List<ServiceItem> services, WidgetRef ref) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        itemBuilder: (context, index) {
          final item = services[index];
          return Container(
            width: 130,
            margin: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: Image.network(
                    item.imageUrl,
                    height: 100,
                    width: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) =>
                        Container(color: Colors.grey[200]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "₹${item.price.toInt()}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            ref.read(cartProvider.notifier).addItem(item.id),
                        child: const Icon(
                          Icons.add_circle,
                          color: Color(0xFF2EAD6F),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCouponSection() {
    return _buildSummaryCard(
      label: "Coupon Code",
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Enter Coupon Code",
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                isDense: true,
                border: InputBorder.none,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5CC28D),
              elevation: 0,
            ),
            child: const Text("Apply", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletInfo() {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF2EAD6F), size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            "Your wallet balance is ₹125, you can redeem ₹10 in this order.",
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildBillDetails(
    List<ServiceItem> cartItems,
    Map<String, int> cart,
    double totalAmount,
  ) {
    return _buildSummaryCard(
      label: "Bill Details",
      child: Column(
        children: [
          ...cartItems.map(
            (item) => _billRow(
              item.title,
              "₹${(item.price * (cart[item.id] ?? 0)).toInt()}",
            ),
          ),
          _billRow("Taxes and Fees", "₹50"),
          _billRow("Coupon Code", "-₹150", isDiscount: true),
          const Divider(height: 30, thickness: 1, color: Color(0xFFEEEEEE)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "₹${(totalAmount + 50 - 150).toInt()}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _billRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: isDiscount ? Colors.red : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Wrapper for the cards with grey title labels
  Widget _buildSummaryCard({required String label, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F1F1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Padding(padding: const EdgeInsets.all(15.0), child: child),
        ],
      ),
    );
  }

  Widget _buildStickyBottom(BuildContext context, WidgetRef ref, double total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Grand Total  |  ₹${(total + 50 - 150).toInt()}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(
                colors: [Color(0xFF67D49E), Color(0xFF2EAD6F)],
              ),
            ),
            child: GestureDetector(
              onTap: () {
                ref.read(cartProvider.notifier).clearCart(); // ✅ CLEAR CART
                context.go('/booking-success');
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Book Slot",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.play_arrow, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for border radius
  BorderRadius RoundedRectangle_circular(double radius) =>
      BorderRadius.circular(radius);
}
