import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vecindario_app/shared/services/payment_service.dart';

void main() {
  group('PaymentService.generateReference', () {
    test('genera referencia con formato type_id_timestamp', () {
      final reference = PaymentService.generateReference(
        PaymentType.cuota,
        'abc123',
      );
      final parts = reference.split('_');

      expect(parts.length, 3);
      expect(parts[0], 'cuota');
      expect(parts[1], 'abc123');
      expect(int.tryParse(parts[2]), isNotNull); // el timestamp es numérico
    });

    test('usa el value del enum como prefijo', () {
      expect(
        PaymentService.generateReference(
          PaymentType.fine,
          'x',
        ).startsWith('fine_'),
        isTrue,
      );
      expect(
        PaymentService.generateReference(
          PaymentType.order,
          'x',
        ).startsWith('order_'),
        isTrue,
      );
    });
  });

  group('PaymentRecord.fromFirestore', () {
    test('convierte amountInCents a pesos dividiendo por 100', () {
      final record = PaymentRecord.fromFirestore({
        'reference': 'cuota_1_123',
        'amountInCents': 50000,
        'type': 'cuota',
        'status': 'approved',
        'transactionId': 'txn_1',
      }, 'doc-1');

      expect(record.amount, 500);
      expect(record.reference, 'cuota_1_123');
      expect(record.type, PaymentType.cuota);
      expect(record.status, PaymentStatus.approved);
      expect(record.transactionId, 'txn_1');
    });

    test('usa el campo amount cuando no viene amountInCents', () {
      final record = PaymentRecord.fromFirestore({
        'reference': 'r',
        'amount': 300,
        'type': 'order',
        'status': 'pending',
      }, 'doc-2');

      expect(record.amount, 300);
      expect(record.type, PaymentType.order);
    });

    test('cae en valores por defecto ante type y status desconocidos', () {
      final record = PaymentRecord.fromFirestore({
        'reference': 'r',
        'amount': 0,
        'type': 'inexistente',
        'status': 'raro',
      }, 'doc-3');

      expect(record.type, PaymentType.cuota);
      expect(record.status, PaymentStatus.pending);
    });

    test('mapea processedAt a createdAt cuando está presente', () {
      final record = PaymentRecord.fromFirestore({
        'reference': 'r',
        'amount': 100,
        'type': 'booking',
        'status': 'approved',
        'processedAt': Timestamp.fromDate(DateTime(2026, 1, 15)),
      }, 'doc-4');

      expect(record.createdAt, DateTime(2026, 1, 15));
      expect(record.type, PaymentType.booking);
    });
  });
}
