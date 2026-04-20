import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vecindario_app/features/premium/models/fine_model.dart';

void main() {
  group('FineStatus', () {
    test('fromString parsea correctamente', () {
      expect(FineStatus.fromString('notified'), FineStatus.notified);
      expect(FineStatus.fromString('defense'), FineStatus.defense);
      expect(FineStatus.fromString('confirmed'), FineStatus.confirmed);
      expect(FineStatus.fromString('paid'), FineStatus.paid);
      expect(FineStatus.fromString('voided'), FineStatus.voided);
      expect(FineStatus.fromString('invalid'), FineStatus.notified);
    });
  });

  group('FineModel', () {
    test('fromFirestore crea modelo correctamente', () {
      final now = DateTime(2026, 4, 10);
      final deadline = DateTime(2026, 4, 15);
      final data = {
        'unitNumber': 'T2-801',
        'residentUid': 'uid1',
        'amount': 200000,
        'reason': 'Ruido excesivo',
        'manualArticle': 'Art. 23 — Horarios de silencio',
        'evidenceURLs': ['url1.jpg', 'url2.jpg'],
        'status': 'defense',
        'defenseText': 'El evento terminó a las 10:30pm',
        'defenseDeadline': Timestamp.fromDate(deadline),
        'createdAt': Timestamp.fromDate(now),
      };

      final fine = FineModel.fromFirestore(data, 'fine1');

      expect(fine.id, 'fine1');
      expect(fine.unitNumber, 'T2-801');
      expect(fine.amount, 200000);
      expect(fine.status, FineStatus.defense);
      expect(fine.evidenceURLs.length, 2);
      expect(fine.defenseText, 'El evento terminó a las 10:30pm');
      expect(fine.manualArticle, 'Art. 23 — Horarios de silencio');
    });

    test('canDefend es true solo en estados notified o defense', () {
      FineModel makeFine(FineStatus status) => FineModel(
            id: '1',
            unitNumber: 'T1-101',
            amount: 100000,
            reason: 'Test',
            status: status,
            createdAt: DateTime.now(),
          );

      expect(makeFine(FineStatus.notified).canDefend, true);
      expect(makeFine(FineStatus.defense).canDefend, true);
      expect(makeFine(FineStatus.confirmed).canDefend, false);
      expect(makeFine(FineStatus.paid).canDefend, false);
      expect(makeFine(FineStatus.voided).canDefend, false);
    });

    test('canPay es true solo cuando está confirmada', () {
      FineModel makeFine(FineStatus status) => FineModel(
            id: '1',
            unitNumber: 'T1-101',
            amount: 100000,
            reason: 'Test',
            status: status,
            createdAt: DateTime.now(),
          );

      expect(makeFine(FineStatus.confirmed).canPay, true);
      expect(makeFine(FineStatus.notified).canPay, false);
      expect(makeFine(FineStatus.paid).canPay, false);
    });

    test('daysLeftForDefense calcula correctamente', () {
      final fine = FineModel(
        id: '1',
        unitNumber: 'T1-101',
        amount: 100000,
        reason: 'Test',
        // 3 días + 1 minuto para evitar truncamiento por microsegundos
        defenseDeadline: DateTime.now().add(
          const Duration(days: 3, minutes: 1),
        ),
        createdAt: DateTime.now(),
      );

      expect(fine.daysLeftForDefense, 3);
    });

    test('toFirestore serializa correctamente', () {
      final fine = FineModel(
        id: '1',
        unitNumber: 'T1-101',
        amount: 150000,
        reason: 'Mascotas',
        status: FineStatus.notified,
        createdAt: DateTime(2026, 4, 1),
      );

      final data = fine.toFirestore();

      expect(data['unitNumber'], 'T1-101');
      expect(data['amount'], 150000);
      expect(data['status'], 'notified');
    });
  });
}
