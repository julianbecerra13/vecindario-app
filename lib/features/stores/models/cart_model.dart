class CartItem {
  final String storeItemId;
  final String name;
  final int price;
  final String? variant;
  int quantity;

  CartItem({
    required this.storeItemId,
    required this.name,
    required this.price,
    this.variant,
    this.quantity = 1,
  });

  int get total => price * quantity;
  String get lineId => '$storeItemId::${variant ?? ''}';
  String get displayName => variant == null ? name : '$name · $variant';
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
    final existing = items.where((i) => i.lineId == item.lineId);
    if (existing.isNotEmpty) {
      existing.first.quantity++;
    } else {
      items.add(item);
    }
  }

  void removeItem(String storeItemId, {String? variant}) {
    final matching = items.where((i) => i.storeItemId == storeItemId).toList();
    final existing = variant == null
        ? matching.reversed.take(1)
        : matching.where((i) => i.variant == variant);
    if (existing.isNotEmpty) {
      if (existing.first.quantity > 1) {
        existing.first.quantity--;
      } else {
        items.removeWhere((i) => i.lineId == existing.first.lineId);
      }
    }
  }

  int getQuantity(String storeItemId) {
    final existing = items.where((i) => i.storeItemId == storeItemId);
    if (existing.isEmpty) return 0;
    return existing.fold(0, (sum, item) => sum + item.quantity);
  }

  void clear() => items.clear();
}
