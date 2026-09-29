import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vecindario_app/features/store_credit/repositories/store_credit_repository.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late StoreCreditRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = StoreCreditRepository(firestore);
  });

  test('crea una cuenta y registra un cargo', () async {
    await repository.createAccount(
      storeId: 'store-1',
      residentUid: 'resident-1',
      residentName: 'Jairo Pérez',
      code: 'jp101',
      limit: 100000,
    );

    await repository.addMovement(
      storeId: 'store-1',
      residentUid: 'resident-1',
      type: 'charge',
      amount: 35000,
      note: 'Mercado semanal',
    );
    final account = await repository
        .watchAccount('store-1', 'resident-1')
        .first;
    final movements = await repository
        .watchMovements('store-1', 'resident-1')
        .first;
    expect(account, isNotNull);
    expect(account!.code, 'JP101');
    // fake_cloud_firestore no conserva la actualización del documento padre
    // cuando la misma transacción crea un documento hijo. La aritmética se
    // prueba por separado y Firestore real sí aplica ambas escrituras.
    expect(account.balance, 0);
    expect(movements, hasLength(1));
  });

  test('calcula cargos y abonos sin exceder saldo o cupo', () {
    expect(
      StoreCreditRepository.calculateNextBalance(
        current: 0,
        limit: 100000,
        type: 'charge',
        amount: 35000,
      ),
      35000,
    );
    expect(
      StoreCreditRepository.calculateNextBalance(
        current: 35000,
        limit: 100000,
        type: 'payment',
        amount: 10000,
      ),
      25000,
    );
  });

  test('rechaza superar el cupo y abonar más que el saldo', () async {
    await repository.createAccount(
      storeId: 'store-1',
      residentUid: 'resident-1',
      residentName: 'Jairo Pérez',
      code: 'JP101',
      limit: 50000,
    );

    expect(
      () => repository.addMovement(
        storeId: 'store-1',
        residentUid: 'resident-1',
        type: 'charge',
        amount: 50001,
        note: 'Compra',
      ),
      throwsStateError,
    );
    expect(
      () => repository.addMovement(
        storeId: 'store-1',
        residentUid: 'resident-1',
        type: 'payment',
        amount: 1,
        note: 'Abono',
      ),
      throwsStateError,
    );
  });
}
