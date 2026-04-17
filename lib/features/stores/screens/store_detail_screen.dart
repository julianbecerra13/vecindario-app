import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/shared/providers/community_provider.dart';
import 'package:vecindario_app/features/stores/models/order_model.dart';
import 'package:vecindario_app/features/stores/providers/cart_provider.dart';
import 'package:vecindario_app/features/stores/providers/stores_provider.dart';
import 'package:vecindario_app/features/stores/widgets/checkout_bar.dart';
import 'package:vecindario_app/features/stores/widgets/store_item_tile.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/services/payment_service.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';

enum PaymentMethod { cashOnDelivery, online }

class StoreDetailScreen extends ConsumerStatefulWidget {
  final String storeId;

  const StoreDetailScreen({super.key, required this.storeId});

  @override
  ConsumerState<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends ConsumerState<StoreDetailScreen> {
  bool _isOrdering = false;
  PaymentMethod _paymentMethod = PaymentMethod.cashOnDelivery;

  @override
  void initState() {
    super.initState();
    _initCart();
  }

  Future<void> _initCart() async {
    final store =
        await ref.read(storesRepositoryProvider).getStore(widget.storeId);
    if (store != null && mounted) {
      ref.read(cartProvider.notifier).initCart(store.id, store.name);
    }
  }

  Future<void> _handleCheckout() async {
    final cart = ref.read(cartProvider);
    final user = ref.read(currentUserProvider).value;
    final community = ref.read(currentCommunityProvider).value;

    if (cart == null || cart.isEmpty || user == null || community == null) return;

    final fee = OrderModel.calculateServiceFee(community.estrato);
    final subtotal = cart.subtotal;

    setState(() => _isOrdering = true);

    try {
      final order = OrderModel(
        id: '',
        storeId: cart.storeId,
        storeName: cart.storeName,
        buyerUid: user.id,
        buyerName: user.displayName,
        buyerApartment: user.unitInfo,
        items: cart.items
            .map((item) => OrderItemModel(
                  name: item.name,
                  price: item.price,
                  quantity: item.quantity,
                ))
            .toList(),
        subtotal: subtotal,
        serviceFee: fee,
        total: subtotal + fee,
        paymentMethod: _paymentMethod == PaymentMethod.online ? 'online' : 'cash',
        createdAt: DateTime.now(),
      );

      final orderId =
          await ref.read(storesRepositoryProvider).createOrder(order);

      // Si eligió pago online, abrir Wompi
      if (_paymentMethod == PaymentMethod.online) {
        final paymentService = ref.read(paymentServiceProvider);
        await paymentService.startPayment(
          reference: PaymentService.generateReference(PaymentType.order, orderId),
          amountCOP: subtotal + fee,
          customerEmail: user.email,
          type: PaymentType.order,
        );
      }

      ref.read(cartProvider.notifier).clear();

      if (mounted) {
        context.showSuccessSnackBar('Pedido creado');
        context.push('/stores/order/$orderId');
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Error al crear el pedido');
      }
    } finally {
      if (mounted) setState(() => _isOrdering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(storeItemsProvider(widget.storeId));
    final cart = ref.watch(cartProvider);
    final community = ref.watch(currentCommunityProvider).value;
    final estrato = community?.estrato ?? 3;
    final fee = OrderModel.calculateServiceFee(estrato);

    return Scaffold(
      appBar: AppBar(
        title: Text(cart?.storeName ?? 'Tienda'),
      ),
      body: itemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text('Esta tienda no tiene productos aún'),
            );
          }
          return ListView(
            padding: EdgeInsets.only(
              bottom: cart != null && !cart.isEmpty ? 200 : AppSizes.md,
            ),
            children: [
              ...List.generate(items.length, (i) {
                final item = items[i];
                final quantity = cart?.getQuantity(item.id) ?? 0;
                return StoreItemTile(
                  item: item,
                  quantity: quantity,
                  onAdd: () => ref.read(cartProvider.notifier).addItem(
                        storeItemId: item.id,
                        name: item.name,
                        price: item.price,
                      ),
                  onRemove: () =>
                      ref.read(cartProvider.notifier).removeItem(item.id),
                );
              }),
              // Selector de método de pago
              if (cart != null && !cart.isEmpty) ...[
                const SizedBox(height: AppSizes.md),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Método de pago',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      _PaymentMethodTile(
                        icon: Icons.money,
                        title: 'Contra entrega',
                        subtitle: 'Paga al recibir tu pedido',
                        selected: _paymentMethod == PaymentMethod.cashOnDelivery,
                        onTap: () => setState(
                            () => _paymentMethod = PaymentMethod.cashOnDelivery),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      _PaymentMethodTile(
                        icon: Icons.credit_card,
                        title: 'Pago en línea',
                        subtitle: 'PSE, tarjeta o Nequi via Wompi',
                        selected: _paymentMethod == PaymentMethod.online,
                        onTap: () =>
                            setState(() => _paymentMethod = PaymentMethod.online),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: cart != null && !cart.isEmpty
          ? CheckoutBar(
              subtotal: cart.subtotal,
              serviceFee: fee,
              estrato: estrato,
              onCheckout: _handleCheckout,
              isLoading: _isOrdering,
              paymentLabel: _paymentMethod == PaymentMethod.online
                  ? 'Pagar en línea'
                  : 'Pedir (contra entrega)',
            )
          : null,
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.sm + 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
          color: selected
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? AppColors.primary : AppColors.textHint,
                size: 22),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textHint),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
