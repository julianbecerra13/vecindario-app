import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecindario_app/core/constants/firestore_paths.dart';
import 'package:vecindario_app/features/stores/models/order_model.dart';
import 'package:vecindario_app/features/stores/models/store_item_model.dart';
import 'package:vecindario_app/features/stores/models/store_model.dart';
import 'package:vecindario_app/shared/models/review_model.dart';

class StoresRepository {
  final FirebaseFirestore _firestore;

  StoresRepository(this._firestore);

  Stream<List<StoreModel>> watchStores(String communityId) {
    return _firestore
        .collection(FirestorePaths.stores)
        .where('communityId', isEqualTo: communityId)
        .where('active', isEqualTo: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => StoreModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<StoreModel?> getStore(String storeId) async {
    final doc = await _firestore
        .collection(FirestorePaths.stores)
        .doc(storeId)
        .get();
    if (!doc.exists) return null;
    return StoreModel.fromFirestore(doc.data()!, doc.id);
  }

  Stream<List<StoreItemModel>> watchStoreItems(String storeId) {
    return _firestore
        .collection(FirestorePaths.stores)
        .doc(storeId)
        .collection('items')
        .where('available', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => StoreItemModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<String> createOrder(OrderModel order) async {
    final doc = await _firestore
        .collection(FirestorePaths.orders)
        .add(order.toFirestore());
    return doc.id;
  }

  Stream<OrderModel?> watchOrder(String orderId) {
    return _firestore
        .collection(FirestorePaths.orders)
        .doc(orderId)
        .snapshots()
        .map((doc) {
          if (!doc.exists || doc.data() == null) return null;
          return OrderModel.fromFirestore(doc.data()!, doc.id);
        });
  }

  Stream<List<OrderModel>> watchMyOrders(String buyerUid) {
    return _firestore
        .collection(FirestorePaths.orders)
        .where('buyerUid', isEqualTo: buyerUid)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<OrderModel>> watchStoreOrders(String storeId, String ownerUid) {
    // Solo filtro por storeOwnerUid (rule requires it). Ordeno in-memory
    // para no depender de índice compuesto en la colección orders.
    return _firestore
        .collection(FirestorePaths.orders)
        .where('storeOwnerUid', isEqualTo: ownerUid)
        .snapshots()
        .map((snap) {
          final orders = snap.docs
              .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
              .where((o) => o.storeId == storeId)
              .toList();
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final data = <String, dynamic>{'status': status.name};
    if (status == OrderStatus.confirmed) {
      data['confirmedAt'] = FieldValue.serverTimestamp();
    } else if (status == OrderStatus.delivered) {
      data['deliveredAt'] = FieldValue.serverTimestamp();
    }
    await _firestore
        .collection(FirestorePaths.orders)
        .doc(orderId)
        .update(data);
  }

  Future<void> submitOrderReview({
    required String orderId,
    required ReviewModel review,
  }) async {
    final batch = _firestore.batch();

    // Crear reseña
    batch.set(
      _firestore.collection(FirestorePaths.reviews).doc(),
      review.toFirestore(),
    );

    // Marcar pedido como calificado
    batch.update(_firestore.collection(FirestorePaths.orders).doc(orderId), {
      'rated': true,
    });

    await batch.commit();
  }

  Stream<List<StoreModel>> getStoresForOwner(String ownerUid) {
    return _firestore
        .collection(FirestorePaths.stores)
        .where('ownerUid', isEqualTo: ownerUid)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => StoreModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<StoreItemModel>> watchAllStoreItems(String storeId) {
    return _firestore
        .collection(FirestorePaths.stores)
        .doc(storeId)
        .collection('items')
        .orderBy('sortOrder')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => StoreItemModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<String> createStore(StoreModel store) async {
    final doc = await _firestore
        .collection(FirestorePaths.stores)
        .add(store.toFirestore());
    return doc.id;
  }

  Future<void> updateStore(String storeId, Map<String, dynamic> data) async {
    await _firestore
        .collection(FirestorePaths.stores)
        .doc(storeId)
        .update(data);
  }

  Future<void> addStoreItem(String storeId, StoreItemModel item) async {
    await _firestore
        .collection(FirestorePaths.stores)
        .doc(storeId)
        .collection('items')
        .add(item.toFirestore());
  }

  Future<void> updateStoreItem(
    String storeId,
    String itemId,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection(FirestorePaths.stores)
        .doc(storeId)
        .collection('items')
        .doc(itemId)
        .update(data);
  }

  Future<void> deleteStoreItem(String storeId, String itemId) async {
    await _firestore
        .collection(FirestorePaths.stores)
        .doc(storeId)
        .collection('items')
        .doc(itemId)
        .delete();
  }
}
