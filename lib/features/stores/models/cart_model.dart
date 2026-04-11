class CartItem {
  final String storeItemId;
  final String name;
  final int price;
  int quantity;

  CartItem({
    required this.storeItemId,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  int get total => price * quantity;
}

class CartModel {
  final String storeId;
  final String storeName;
  final List<CartItem> items;

  CartModel({
    required this.storeId,
    required this.storeName,
    List<CartItem>? items,
  }) : items = items ?? [];

  int get subtotal => items.fold(0, (sum, item) => sum + item.total);
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;

  void addItem(CartItem item) {
    final existing = items.where((i) => i.storeItemId == item.storeItemId);
    if (existing.isNotEmpty) {
      existing.first.quantity++;
    } else {
      items.add(item);
    }
  }

  void removeItem(String storeItemId) {
    final existing = items.where((i) => i.storeItemId == storeItemId);
    if (existing.isNotEmpty) {
      if (existing.first.quantity > 1) {
        existing.first.quantity--;
      } else {
        items.removeWhere((i) => i.storeItemId == storeItemId);
      }
    }
  }

  int getQuantity(String storeItemId) {
    final existing = items.where((i) => i.storeItemId == storeItemId);
    if (existing.isEmpty) return 0;
    return existing.first.quantity;
  }

  void clear() => items.clear();
}
