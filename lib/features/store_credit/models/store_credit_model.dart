import 'package:cloud_firestore/cloud_firestore.dart';

class StoreCreditAccount {
  const StoreCreditAccount({
    required this.residentUid,
    required this.residentName,
    required this.code,
    required this.limit,
    required this.balance,
    required this.active,
  });
  final String residentUid;
  final String residentName;
  final String code;
  final int limit;
  final int balance;
  final bool active;

  factory StoreCreditAccount.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return StoreCreditAccount(
      residentUid: doc.id,
      residentName: data['residentName'] as String? ?? '',
      code: data['code'] as String? ?? '',
      limit: data['limit'] as int? ?? 0,
      balance: data['balance'] as int? ?? 0,
      active: data['active'] as bool? ?? true,
    );
  }

  int get available => limit - balance;
}

class StoreCreditMovement {
  const StoreCreditMovement({
    required this.id,
    required this.type,
    required this.amount,
    required this.note,
    required this.createdAt,
  });
  final String id;
  final String type;
  final int amount;
  final String note;
  final DateTime createdAt;

  factory StoreCreditMovement.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return StoreCreditMovement(
      id: doc.id,
      type: data['type'] as String? ?? 'charge',
      amount: data['amount'] as int? ?? 0,
      note: data['note'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
