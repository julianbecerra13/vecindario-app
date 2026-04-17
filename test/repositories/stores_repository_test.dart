import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vecindario_app/features/stores/models/order_model.dart';
import 'package:vecindario_app/features/stores/repositories/stores_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late StoresRepository repo;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repo = StoresRepository(fakeFirestore);
  });

  group('StoresRepository', () {
    test('watchStores devuelve solo tiendas activas de la comunidad', () async {
      await fakeFirestore.collection('stores').doc('store1').set({
        'communityId': 'comm1',
        'name': 'Tienda Activa',
        'active': true,
      });

      await fakeFirestore.collection('stores').doc('store2').set({
        'communityId': 'comm1',
        'name': 'Tienda Inactiva',
        'active': false,
      });

      await fakeFirestore.collection('stores').doc('store3').set({
        'communityId': 'comm2',
        'name': 'Tienda Otra Comunidad',
        'active': true,
      });

      final stores = await repo.watchStores('comm1').first;
      expect(stores.length, 1);
      expect(stores.first.name, 'Tienda Activa');
    });

    test('createOrder retorna el ID creado', () async {
      final order = OrderModel(
        id: 'o1',
        buyerUid: 'u1',
        buyerName: 'Juan',
        storeId: 'store1',
        storeName: 'Mi Tienda',
        items: [],
        subtotal: 100000,
        serviceFee: 10000,
        total: 110000,
        status: OrderStatus.pending,
        paymentMethod: 'card',
        createdAt: DateTime.now(),
      );

      final orderId = await repo.createOrder(order);
      expect(orderId, isNotEmpty);

      final doc = await fakeFirestore
          .collection('orders')
          .doc(orderId)
          .get();
      expect(doc.exists, true);
      expect(doc['buyerUid'], 'u1');
    });

    test('watchMyOrders filtra por buyerUid', () async {
      await fakeFirestore.collection('orders').doc('o1').set({
        'buyerUid': 'u1',
        'buyerName': 'Juan',
        'storeId': 'store1',
        'storeName': 'Tienda 1',
        'status': 'pending',
        'total': 100000,
        'createdAt': DateTime(2026, 4, 1),
      });

      await fakeFirestore.collection('orders').doc('o2').set({
        'buyerUid': 'u2',
        'buyerName': 'María',
        'storeId': 'store1',
        'storeName': 'Tienda 1',
        'status': 'pending',
        'total': 50000,
        'createdAt': DateTime(2026, 4, 2),
      });

      final myOrders = await repo.watchMyOrders('u1').first;
      expect(myOrders.length, 1);
      expect(myOrders.first.buyerUid, 'u1');
    });

    test('updateOrderStatus escribe el status correctamente', () async {
      await fakeFirestore.collection('orders').doc('o1').set({
        'buyerUid': 'u1',
        'buyerName': 'Juan',
        'storeId': 'store1',
        'storeName': 'Tienda 1',
        'status': 'pending',
        'total': 100000,
        'createdAt': DateTime(2026, 4, 1),
      });

      await repo.updateOrderStatus('o1', OrderStatus.confirmed);

      final doc = await fakeFirestore
          .collection('orders')
          .doc('o1')
          .get();
      expect(doc['status'], 'confirmed');
      expect(doc['confirmedAt'], isNotNull);
    });
  });
}
