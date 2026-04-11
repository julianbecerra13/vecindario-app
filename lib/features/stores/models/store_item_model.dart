class StoreItemModel {
  final String id;
  final String storeId;
  final String name;
  final String? description;
  final int price;
  final String? imageURL;
  final bool available;
  final String? category;
  final int sortOrder;

  const StoreItemModel({
    required this.id,
    required this.storeId,
    required this.name,
    this.description,
    required this.price,
    this.imageURL,
    this.available = true,
    this.category,
    this.sortOrder = 0,
  });

  factory StoreItemModel.fromFirestore(Map<String, dynamic> data, String id) {
    return StoreItemModel(
      id: id,
      storeId: data['storeId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'],
      price: data['price'] ?? 0,
      imageURL: data['imageURL'],
      available: data['available'] ?? true,
      category: data['category'],
      sortOrder: data['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'storeId': storeId,
    'name': name,
    'description': description,
    'price': price,
    'imageURL': imageURL,
    'available': available,
    'category': category,
    'sortOrder': sortOrder,
  };

  String get formattedPrice =>
      '\$${price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.')}';
}
