import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/extensions/l10n_extensions.dart';
import 'package:vecindario_app/shared/providers/community_provider.dart';
import 'package:vecindario_app/features/stores/models/order_model.dart';
import 'package:vecindario_app/features/stores/providers/cart_provider.dart';
import 'package:vecindario_app/features/stores/providers/stores_provider.dart';
import 'package:vecindario_app/features/stores/widgets/checkout_bar.dart';
import 'package:vecindario_app/features/stores/widgets/store_item_tile.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';

enum PaymentMethod { cashOnDelivery, transfer }

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
    final store = await ref
        .read(storesRepositoryProvider)
        .getStore(widget.storeId);
    if (store != null && mounted) {
      ref.read(cartProvider.notifier).initCart(store.id, store.name);
    }
  }

  Future<void> _handleCheckout() async {
    final cart = ref.read(cartProvider);
    final user = ref.read(currentUserProvider).value;
    final community = ref.read(currentCommunityProvider).value;

    if (cart == null || cart.isEmpty || user == null || community == null)
      return;

    final fee = OrderModel.calculateServiceFee(community.estrato);
    final subtotal = cart.subtotal;

    setState(() => _isOrdering = true);

    try {
      final store = await ref
          .read(storesRepositoryProvider)
          .getStore(cart.storeId);
      if (store == null ||
          !store.active ||
          store.communityId != community.id ||
          store.ownerUid.isEmpty) {
        throw StateError('La tienda no esta disponible');
      }
      final order = OrderModel(
        id: '',
        storeId: cart.storeId,
        storeName: cart.storeName,
        storeOwnerUid: store.ownerUid,
        communityId: community.id,
        buyerUid: user.id,
        buyerName: user.displayName,
        buyerApartment: user.unitInfo,
        items: cart.items
            .map(
              (item) => OrderItemModel(
                name: item.name,
                price: item.price,
                quantity: item.quantity,
              ),
            )
            .toList(),
        subtotal: subtotal,
        serviceFee: fee,
        total: subtotal + fee,
        paymentMethod: _paymentMethod == PaymentMethod.transfer
            ? 'transfer'
            : 'cash',
        createdAt: DateTime.now(),
      );

      final orderId = await ref
          .read(storesRepositoryProvider)
          .createOrder(order);

      ref.read(cartProvider.notifier).clear();

      if (mounted) {
        context.showSuccessSnackBar(context.l10n.storeOrderCreated);
        context.push('/stores/order/$orderId');
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(context.l10n.storeOrderCreateError);
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
        title: Text(cart?.storeName ?? context.l10n.storeDefaultTitle),
      ),
      body: itemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text(context.l10n.storeNoItemsMessage));
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
                  onAdd: () => ref
                      .read(cartProvider.notifier)
                      .addItem(
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
                      Text(
                        context.l10n.storePaymentMethodLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      _PaymentMethodTile(
                        icon: Icons.money,
                        title: context.l10n.storeCashOnDeliveryTitle,
                        subtitle: context.l10n.storeCashOnDeliverySubtitle,
                        selected:
                            _paymentMethod == PaymentMethod.cashOnDelivery,
                        onTap: () => setState(
                          () => _paymentMethod = PaymentMethod.cashOnDelivery,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      _PaymentMethodTile(
                        icon: Icons.account_balance,
                        title: 'Transferencia',
                        subtitle:
                            'La tienda confirmará los datos y el comprobante',
                        selected: _paymentMethod == PaymentMethod.transfer,
                        onTap: () => setState(
                          () => _paymentMethod = PaymentMethod.transfer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) =>
            Center(child: Text(context.l10n.errorWithDetail('$e'))),
      ),
      bottomNavigationBar: cart != null && !cart.isEmpty
          ? CheckoutBar(
              subtotal: cart.subtotal,
              serviceFee: fee,
              estrato: estrato,
              onCheckout: _handleCheckout,
              isLoading: _isOrdering,
              paymentLabel: _paymentMethod == PaymentMethod.transfer
                  ? 'Pedir por transferencia'
                  : context.l10n.storeOrderCashLabel,
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
            color: selected ? AppColors.primary : context.colors.border,
            width: selected ? 2 : 1,
          ),
          color: selected
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primary : context.colors.textHint,
              size: 22,
            ),
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
                          : context.colors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
