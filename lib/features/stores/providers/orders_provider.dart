import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/features/stores/models/order_model.dart';
import 'package:vecindario_app/features/stores/providers/stores_provider.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

final myOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(storesRepositoryProvider).watchMyOrders(user.id);
});

final orderDetailProvider = StreamProvider.family<OrderModel?, String>((
  ref,
  orderId,
) {
  return ref.watch(storesRepositoryProvider).watchOrder(orderId);
});
