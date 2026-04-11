import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vecindario_app/features/stores/models/order_model.dart';

void main() {
  group('OrderStatus', () {
    test('fromString parsea correctamente', () {
      expect(OrderStatus.fromString('pending'), OrderStatus.pending);
      expect(OrderStatus.fromString('confirmed'), OrderStatus.confirmed);
      expect(OrderStatus.fromString('inTransit'), OrderStatus.inTransit);
      expect(OrderStatus.fromString('delivered'), OrderStatus.delivered);
      expect(OrderStatus.fromString('cancelled'), OrderStatus.cancelled);
      expect(OrderStatus.fromString('unknown'), OrderStatus.pending);
    });
  });

  group('OrderItemModel', () {
    test('total calcula correctamente', () {
      final item = OrderItemModel(name: 'Leche', price: 4200, quantity: 3);
      expect(item.total, 12600);
    });

    test('fromMap y toMap son inversos', () {
      final map = {'name': 'Pan', 'price': 5800, 'quantity': 2};
      final item = OrderItemModel.fromMap(map);
      final result = item.toMap();
      expect(result['name'], 'Pan');
      expect(result['price'], 5800);
      expect(result['quantity'], 2);
    });
  });

  group('OrderModel', () {
    test('calculateServiceFee devuelve tarifa correcta por estrato', () {
      expect(OrderModel.calculateServiceFee(1), 200);
      expect(OrderModel.calculateServiceFee(2), 200);
      expect(OrderModel.calculateServiceFee(3), 300);
      expect(OrderModel.calculateServiceFee(4), 350);
      expect(OrderModel.calculateServiceFee(5), 450);
      expect(OrderModel.calculateServiceFee(6), 500);
    });

    test('fromFirestore crea modelo correctamente', () {
      final data = {
        'storeId': 'store1',
        'storeName': 'Tienda Don Julio',
        'buyerUid': 'buyer1',
        'buyerName': 'Juan',
        'buyerApartment': 'T1 - Apto 501',
        'items': [
          {'name': 'Leche', 'price': 4200, 'quantity': 2},
        ],
        'subtotal': 8400,
        'serviceFee': 350,
        'total': 8750,
        'status': 'confirmed',
        'paymentMethod': 'cash',
        'createdAt': Timestamp.fromDate(DateTime(2026, 4, 10)),
      };

      final order = OrderModel.fromFirestore(data, 'ord1');

      expect(order.id, 'ord1');
      expect(order.storeName, 'Tienda Don Julio');
      expect(order.items.length, 1);
      expect(order.subtotal, 8400);
      expect(order.serviceFee, 350);
      expect(order.total, 8750);
      expect(order.status, OrderStatus.confirmed);
      expect(order.paymentMethod, 'cash');
    });

    test('itemsSummary formatea correctamente', () {
      final order = OrderModel(
        id: '1',
        storeId: 's1',
        storeName: 'Tienda',
        buyerUid: 'b1',
        buyerName: 'Juan',
        items: [
          OrderItemModel(name: 'Leche', price: 4200, quantity: 2),
          OrderItemModel(name: 'Pan', price: 5800, quantity: 1),
        ],
        subtotal: 14200,
        serviceFee: 350,
        total: 14550,
        createdAt: DateTime.now(),
      );

      expect(order.itemsSummary, 'Leche x2, Pan x1');
    });

    test('paymentMethod default es cash', () {
      final order = OrderModel(
        id: '1',
        storeId: 's1',
        storeName: 'T',
        buyerUid: 'b1',
        buyerName: 'J',
        items: [],
        subtotal: 0,
        serviceFee: 0,
        total: 0,
        createdAt: DateTime.now(),
      );
      expect(order.paymentMethod, 'cash');
    });
  });
}
