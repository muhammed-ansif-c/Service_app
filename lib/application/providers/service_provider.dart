import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:service_app/domain/models/service_item.dart';

final categoryProvider = StateProvider<String>((ref) => "Maid Services");
class CartNotifier extends StateNotifier<Map<String, int>> {
  CartNotifier() : super({});

  void clearCart() {
    state = {};
  }

  void addItem(String id) {
    state = {...state, id: (state[id] ?? 0) + 1};
  }

  void removeItem(String id) {
    if (!state.containsKey(id)) return;
    if (state[id] == 1) {
      final newState = Map<String, int>.from(state);
      newState.remove(id);
      state = newState;
    } else {
      state = {...state, id: state[id]! - 1};
    }
  }

  int get totalItems => state.values.fold(0, (sum, q) => sum + q);

  double totalPrice(List<ServiceItem> items) {
    double total = 0;
    state.forEach((id, qty) {
      final item = items.firstWhere((e) => e.id == id);
      total += item.price * qty;
    });
    return total;
  }
}

final cartProvider =
    StateNotifierProvider<CartNotifier, Map<String, int>>(
        (ref) => CartNotifier());
final servicesListProvider = Provider<List<ServiceItem>>((ref) => [
  ServiceItem(
    id: '1',
    title: 'Home Cleaning',
    duration: '60 Minutes',
    price: 499.00,
    rating: '4.2/5',
    orders: '23 Orders',
    imageUrl: 'assets/images/cleaning.png',
  ),
  ServiceItem(
    id: '2',
    title: 'Carpet Cleaning',
    duration: '60 Minutes',
    price: 699.00,
    rating: '4.5/5',
    orders: '45 Orders',
    imageUrl: 'assets/images/carpet.png',
  ),
  ServiceItem(
    id: '3',
    title: 'Sofa Cleaning',
    duration: '60 Minutes',
    price: 999.00,
    rating: '4.8/5',
    orders: '78 Orders',
    imageUrl: 'assets/images/sofa.png',
  ),
  ServiceItem(
    id: '4',
    title: 'Bathroom Cleaning',
    duration: '60 Minutes',
    price: 499.00,
    rating: '4.2/5',
    orders: '23 Orders',
    imageUrl: 'assets/images/bathroom.png',
  ),
  ServiceItem(
    id: '5',
    title: 'Kitchen Cleaning',
    duration: '90 Minutes',
    price: 799.00,
    rating: '4.6/5',
    orders: '50 Orders',
    imageUrl: 'assets/images/kitchen.png',
  ),
]);
