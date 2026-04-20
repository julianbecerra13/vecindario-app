import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/features/stores/models/cart_model.dart';

class CartNotifier extends StateNotifier<CartModel?> {
  CartNotifier() : super(null);

  void initCart(String storeId, String storeName) {
    if (state?.storeId == storeId) return;
    state = CartModel(storeId: storeId, storeName: storeName);
  }

  void addItem({
    required String storeItemId,
    required String name,
    required int price,
  }) {
    if (state == null) return;
    state!.addItem(
      CartItem(storeItemId: storeItemId, name: name, price: price),
    );
    state = CartModel(
      storeId: state!.storeId,
      storeName: state!.storeName,
      items: List.from(state!.items),
    );
  }

  void removeItem(String storeItemId) {
    if (state == null) return;
    state!.removeItem(storeItemId);
    state = CartModel(
      storeId: state!.storeId,
      storeName: state!.storeName,
      items: List.from(state!.items),
    );
  }

  void clear() {
    if (state == null) return;
    state = CartModel(storeId: state!.storeId, storeName: state!.storeName);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartModel?>((ref) {
  return CartNotifier();
});

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider)?.itemCount ?? 0;
});
