import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';

enum OrderStatus {
  pending('Pendiente', AppColors.warning, Icons.hourglass_top),
  confirmed('Confirmado', AppColors.info, Icons.check_circle_outline),
  inTransit('En camino', AppColors.primary, Icons.delivery_dining),
  delivered('Entregado', AppColors.success, Icons.check_circle),
  cancelled('Cancelado', AppColors.error, Icons.cancel);

  final String label;
  final Color color;
  final IconData icon;
  const OrderStatus(this.label, this.color, this.icon);

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

class OrderItemModel {
  final String name;
  final int price;
  final int quantity;

  const OrderItemModel({
    required this.name,
    required this.price,
    required this.quantity,
  });

  int get total => price * quantity;

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      name: map['name'] ?? '',
      price: map['price'] ?? 0,
      quantity: map['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'price': price,
    'quantity': quantity,
  };
}

class OrderModel {
  final String id;
  final String storeId;
  final String storeName;
  final String buyerUid;
  final String buyerName;
  final String? buyerApartment;
  final List<OrderItemModel> items;
  final int subtotal;
  final int serviceFee;
  final int total;
  final OrderStatus status;
  final String paymentMethod;
  final String? note;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? deliveredAt;

  const OrderModel({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.buyerUid,
    required this.buyerName,
    this.buyerApartment,
    required this.items,
    required this.subtotal,
    required this.serviceFee,
    required this.total,
    this.status = OrderStatus.pending,
    this.paymentMethod = 'cash',
    this.note,
    required this.createdAt,
    this.confirmedAt,
    this.deliveredAt,
  });

  factory OrderModel.fromFirestore(Map<String, dynamic> data, String id) {
    final items = (data['items'] as List?)
            ?.map((e) => OrderItemModel.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [];
    return OrderModel(
      id: id,
      storeId: data['storeId'] ?? '',
      storeName: data['storeName'] ?? '',
      buyerUid: data['buyerUid'] ?? '',
      buyerName: data['buyerName'] ?? '',
      buyerApartment: data['buyerApartment'],
      items: items,
      subtotal: data['subtotal'] ?? 0,
      serviceFee: data['serviceFee'] ?? 0,
      total: data['total'] ?? 0,
      status: OrderStatus.fromString(data['status'] ?? 'pending'),
      paymentMethod: data['paymentMethod'] ?? 'cash',
      note: data['note'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      confirmedAt: (data['confirmedAt'] as Timestamp?)?.toDate(),
      deliveredAt: (data['deliveredAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'storeId': storeId,
    'storeName': storeName,
    'buyerUid': buyerUid,
    'buyerName': buyerName,
    'buyerApartment': buyerApartment,
    'items': items.map((e) => e.toMap()).toList(),
    'subtotal': subtotal,
    'serviceFee': serviceFee,
    'total': total,
    'status': status.name,
    'paymentMethod': paymentMethod,
    'note': note,
    'createdAt': Timestamp.fromDate(createdAt),
    if (confirmedAt != null) 'confirmedAt': Timestamp.fromDate(confirmedAt!),
    if (deliveredAt != null) 'deliveredAt': Timestamp.fromDate(deliveredAt!),
  };

  String get itemsSummary =>
      items.map((e) => '${e.name} x${e.quantity}').join(', ');

  static int calculateServiceFee(int estrato) {
    const fees = [200, 200, 300, 350, 450, 500];
    if (estrato < 1 || estrato > 6) return 300;
    return fees[estrato - 1];
  }
}

String formatCOP(int amount) {
  return '\$${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.')}';
}
