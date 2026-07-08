import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vecindario_app/core/constants/firestore_paths.dart';
import 'package:vecindario_app/features/premium/providers/premium_repository.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late PremiumRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = PremiumRepository(firestore);
  });

  group('PremiumRepository - Finanzas', () {
    test('watchBudgets mapea cada documento a categoria -> monto', () async {
      const communityId = 'comm-1';
      await firestore.collection(FirestorePaths.budgets(communityId)).add(
        {'category': 'Mantenimiento', 'amount': 500000},
      );
      await firestore.collection(FirestorePaths.budgets(communityId)).add(
        {'category': 'Seguridad', 'amount': 800000},
      );

      final budgets = await repository.watchBudgets(communityId).first;

      expect(budgets.length, 2);
      expect(budgets['Mantenimiento'], 500000);
      expect(budgets['Seguridad'], 800000);
    });

    test('watchBudgets devuelve un mapa vacío cuando no hay presupuestos', () async {
      final budgets = await repository.watchBudgets('sin-datos').first;
      expect(budgets, isEmpty);
    });

    test('watchAccountStatements permite separar morosos de quienes están al día',
        () async {
      const communityId = 'comm-1';
      await firestore
          .collection(FirestorePaths.accountStatements(communityId))
          .add({
        'unitNumber': '101',
        'residentUid': 'user-1',
        'balance': 150000,
        'lastUpdated': Timestamp.now(),
      });
      await firestore
          .collection(FirestorePaths.accountStatements(communityId))
          .add({
        'unitNumber': '102',
        'residentUid': 'user-2',
        'balance': 0,
        'lastUpdated': Timestamp.now(),
      });

      final statements = await repository.watchAccountStatements(communityId).first;

      expect(statements.length, 2);
      final morosos = statements.where((s) => s.balance > 0).toList();
      expect(morosos.length, 1);
      expect(morosos.first.unitNumber, '101');
      expect(morosos.first.isUpToDate, false);
    });
  });
}
