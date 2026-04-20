import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';

/// Tipos de pago soportados
enum PaymentType {
  cuota('cuota', 'Cuota de administración'),
  booking('booking', 'Reserva de zona social'),
  fine('fine', 'Pago de multa'),
  order('order', 'Pedido de tienda');

  final String value;
  final String label;
  const PaymentType(this.value, this.label);
}

/// Estado de un pago
enum PaymentStatus {
  pending('pending'),
  approved('approved'),
  failed('failed'),
  voided('voided');

  final String value;
  const PaymentStatus(this.value);
}

/// Modelo de pago
class PaymentRecord {
  final String id;
  final String reference;
  final int amount;
  final PaymentType type;
  final PaymentStatus status;
  final String? transactionId;
  final DateTime createdAt;

  const PaymentRecord({
    required this.id,
    required this.reference,
    required this.amount,
    required this.type,
    this.status = PaymentStatus.pending,
    this.transactionId,
    required this.createdAt,
  });

  factory PaymentRecord.fromFirestore(Map<String, dynamic> data, String id) {
    return PaymentRecord(
      id: id,
      reference: data['reference'] ?? '',
      amount: data['amountInCents'] != null
          ? (data['amountInCents'] as int) ~/ 100
          : data['amount'] ?? 0,
      type: PaymentType.values.firstWhere(
        (e) => e.value == (data['type'] ?? ''),
        orElse: () => PaymentType.cuota,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.value == (data['status'] ?? ''),
        orElse: () => PaymentStatus.pending,
      ),
      transactionId: data['transactionId'],
      createdAt:
          (data['processedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// Servicio de pagos con Wompi
class PaymentService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// Llave pública de Wompi (sandbox para desarrollo)
  static const _wompiPublicKey =
      'pub_stagtest_g2u0HQd3ZMh05hsSgTS2lUV8t3s4mOt7';

  /// URL base de Wompi checkout
  static const _wompiCheckoutBase = 'https://checkout.wompi.co/p/';

  PaymentService(this._firestore, this._auth);

  /// Iniciar pago con Wompi (abre widget de checkout)
  Future<bool> startPayment({
    required String reference,
    required int amountCOP,
    required String customerEmail,
    required PaymentType type,
    String currency = 'COP',
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('No autenticado');
    }

    // Guardar intención de pago en Firestore
    await _firestore.collection('payment_intents').add({
      'uid': uid,
      'reference': reference,
      'amount': amountCOP,
      'amountInCents': amountCOP * 100,
      'currency': currency,
      'type': type.value,
      'status': 'pending',
      'customerEmail': customerEmail,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Construir URL de checkout de Wompi
    final uri = Uri.parse(_wompiCheckoutBase).replace(
      queryParameters: {
        'public-key': _wompiPublicKey,
        'currency': currency,
        'amount-in-cents': '${amountCOP * 100}',
        'reference': reference,
        'customer-data:email': customerEmail,
      },
    );

    // Abrir en navegador
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }

  /// Consultar estado de un pago por referencia
  Stream<PaymentRecord?> watchPayment(String reference) {
    return _firestore
        .collection('payments')
        .where('reference', isEqualTo: reference)
        .limit(1)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return null;
          return PaymentRecord.fromFirestore(
            snap.docs.first.data(),
            snap.docs.first.id,
          );
        });
  }

  /// Generar referencia única para un pago
  static String generateReference(PaymentType type, String id) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${type.value}_${id}_$timestamp';
  }
}

/// Provider del servicio de pagos
final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
});

/// Widget reutilizable de botón de pago
class PaymentButton extends ConsumerWidget {
  final String label;
  final int amountCOP;
  final String reference;
  final PaymentType type;
  final String customerEmail;
  final VoidCallback? onSuccess;

  const PaymentButton({
    super.key,
    required this.label,
    required this.amountCOP,
    required this.reference,
    required this.type,
    required this.customerEmail,
    this.onSuccess,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton.icon(
        onPressed: () async {
          final service = ref.read(paymentServiceProvider);
          final launched = await service.startPayment(
            reference: reference,
            amountCOP: amountCOP,
            customerEmail: customerEmail,
            type: type,
          );
          if (!launched && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se pudo abrir el sistema de pago'),
              ),
            );
          }
        },
        icon: const Icon(Icons.credit_card),
        label: Text('$label — \$${_formatNumber(amountCOP)}'),
      ),
    );
  }

  String _formatNumber(int n) {
    final str = n.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
