import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/features/feed/screens/feed_screen.dart';
import 'package:vecindario_app/features/stores/models/order_model.dart';
import 'package:vecindario_app/features/stores/providers/cart_provider.dart';
import 'package:vecindario_app/features/stores/providers/stores_provider.dart';
import 'package:vecindario_app/features/stores/widgets/checkout_bar.dart';
import 'package:vecindario_app/features/stores/widgets/store_item_tile.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';

class StoreDetailScreen extends ConsumerStatefulWidget {
  final String storeId;

  const StoreDetailScreen({super.key, required this.storeId});

  @override
  ConsumerState<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends ConsumerState<StoreDetailScreen> {
  bool _isOrdering = false;

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
        createdAt: DateTime.now(),
      );

      final orderId =
          await ref.read(storesRepositoryProvider).createOrder(order);
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
          return ListView.builder(
            padding: EdgeInsets.only(
              bottom: cart != null && !cart.isEmpty ? 120 : AppSizes.md,
            ),
            itemCount: items.length,
            itemBuilder: (_, i) {
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
            },
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
            )
          : null,
    );
  }
}
