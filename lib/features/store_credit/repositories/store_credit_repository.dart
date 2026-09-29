import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecindario_app/features/store_credit/models/store_credit_model.dart';

class StoreCreditRepository {
  const StoreCreditRepository(this._firestore);
  final FirebaseFirestore _firestore;

  static int calculateNextBalance({
    required int current,
    required int limit,
    required String type,
    required int amount,
  }) {
    if (!const {'charge', 'payment'}.contains(type) || amount <= 0) {
      throw ArgumentError('Movimiento inválido');
    }
    final next = type == 'charge' ? current + amount : current - amount;
    if (next < 0 || next > limit) {
      throw StateError('Movimiento fuera del cupo o saldo');
    }
    return next;
  }

  CollectionReference<Map<String, dynamic>> _accounts(String storeId) =>
      _firestore
          .collection('stores')
          .doc(storeId)
          .collection('credit_accounts');

  Stream<List<StoreCreditAccount>> watchAccounts(String storeId) =>
      _accounts(storeId).snapshots().map(
        (snapshot) =>
            snapshot.docs.map(StoreCreditAccount.fromFirestore).toList()
              ..sort((a, b) => a.residentName.compareTo(b.residentName)),
      );

  Stream<StoreCreditAccount?> watchAccount(String storeId, String uid) =>
      _accounts(storeId)
          .doc(uid)
          .snapshots()
          .map(
            (doc) => doc.exists ? StoreCreditAccount.fromFirestore(doc) : null,
          );

  Stream<List<StoreCreditMovement>> watchMovements(
    String storeId,
    String uid,
  ) => _accounts(storeId)
      .doc(uid)
      .collection('movements')
      .orderBy('createdAt', descending: true)
      .limit(100)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map(StoreCreditMovement.fromFirestore).toList(),
      );

  Future<void> createAccount({
    required String storeId,
    required String residentUid,
    required String residentName,
    required String code,
    required int limit,
  }) {
    return _accounts(storeId).doc(residentUid).set({
      'residentName': residentName,
      'code': code.toUpperCase(),
      'limit': limit,
      'balance': 0,
      'active': true,
      'lastMovementId': '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addMovement({
    required String storeId,
    required String residentUid,
    required String type,
    required int amount,
    required String note,
  }) async {
    final accountRef = _accounts(storeId).doc(residentUid);
    final movementRef = accountRef.collection('movements').doc();
    await _firestore.runTransaction((tx) async {
      final snapshot = await tx.get(accountRef);
      final data = snapshot.data();
      if (data == null || data['active'] != true) {
        throw StateError('Cuenta no disponible');
      }
      final current = data['balance'] as int? ?? 0;
      final limit = data['limit'] as int? ?? 0;
      final next = calculateNextBalance(
        current: current,
        limit: limit,
        type: type,
        amount: amount,
      );
      tx.update(accountRef, {
        'balance': next,
        'lastMovementId': movementRef.id,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.set(movementRef, {
        'type': type,
        'amount': amount,
        'note': note,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
