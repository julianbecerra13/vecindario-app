import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/extensions/datetime_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/stores/models/order_model.dart';
import 'package:vecindario_app/features/stores/models/store_item_model.dart';
import 'package:vecindario_app/features/stores/models/store_model.dart';
import 'package:vecindario_app/features/stores/providers/stores_provider.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/widgets/empty_state.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';

final ownerStoreProvider = StreamProvider<StoreModel?>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value(null);
  return ref
      .watch(storesRepositoryProvider)
      .getStoresForOwner(user.id)
      .map((list) => list.isEmpty ? null : list.first);
});

final storeOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final store = ref.watch(ownerStoreProvider).value;
  final user = ref.watch(currentUserProvider).value;
  if (store == null || user == null) return Stream.value([]);
  return ref
      .watch(storesRepositoryProvider)
      .watchStoreOrders(store.id, user.id);
});

final storeAllItemsProvider = StreamProvider<List<StoreItemModel>>((ref) {
  final store = ref.watch(ownerStoreProvider).value;
  if (store == null) return Stream.value([]);
  return ref.watch(storesRepositoryProvider).watchAllStoreItems(store.id);
});

class StorePanelScreen extends ConsumerWidget {
  const StorePanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(ownerStoreProvider);

    return storeAsync.when(
      loading: () => const Scaffold(body: LoadingIndicator()),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Mi Tienda')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (store) {
        if (store == null) return const _NoStoreView();
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text(store.name),
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.receipt_long), text: 'Pedidos'),
                  Tab(icon: Icon(Icons.restaurant_menu), text: 'Productos'),
                  Tab(icon: Icon(Icons.info_outline), text: 'Información'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _OrdersTab(),
                _ItemsTab(store: store),
                _InfoTab(store: store),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============ NO STORE VIEW ============
class _NoStoreView extends ConsumerWidget {
  const _NoStoreView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Tienda')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.storefront,
                size: 80,
                color: AppColors.textHint,
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                'Aún no tienes tienda',
                style: AppTextStyles.heading3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                'Crea tu tienda para empezar a vender productos a tu comunidad',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.xl),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _showCreateStoreDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Crear mi tienda'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCreateStoreDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final deliveryController = TextEditingController(text: '15-25 min');
    final minOrderController = TextEditingController(text: '10000');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Crear tienda'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la tienda',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: deliveryController,
                decoration: const InputDecoration(labelText: 'Tiempo entrega'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: minOrderController,
                decoration: const InputDecoration(labelText: 'Pedido mínimo'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Crear'),
          ),
        ],
      ),
    );

    if (result != true || !context.mounted) return;
    final user = ref.read(currentUserProvider).value;
    final communityId = ref.read(currentCommunityIdProvider);
    if (user == null || communityId == null) {
      context.showErrorSnackBar('No hay comunidad asignada');
      return;
    }

    await ref.read(storesRepositoryProvider).createStore(
          StoreModel(
            id: '',
            ownerUid: user.id,
            communityId: communityId,
            name: nameController.text.trim(),
            description: descController.text.trim(),
            deliveryTime: deliveryController.text.trim(),
            minOrder: int.tryParse(minOrderController.text.trim()) ?? 10000,
            createdAt: DateTime.now(),
          ),
        );
    if (context.mounted) context.showSuccessSnackBar('Tienda creada');
  }
}

// ============ PEDIDOS ============
class _OrdersTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(storeOrdersProvider);

    return ordersAsync.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (orders) {
        if (orders.isEmpty) {
          return const EmptyState(
            icon: Icons.inbox_outlined,
            title: 'Sin pedidos',
            subtitle: 'Los pedidos de tus clientes aparecerán aquí',
          );
        }

        final pending = orders
            .where((o) => o.status == OrderStatus.pending)
            .toList();
        final active = orders
            .where(
              (o) =>
                  o.status == OrderStatus.confirmed ||
                  o.status == OrderStatus.inTransit,
            )
            .toList();
        final completed = orders
            .where(
              (o) =>
                  o.status == OrderStatus.delivered ||
                  o.status == OrderStatus.cancelled,
            )
            .toList();

        return ListView(
          padding: const EdgeInsets.all(AppSizes.md),
          children: [
            Row(
              children: [
                _StatChip(
                  label: 'Pendientes',
                  count: pending.length,
                  color: AppColors.warning,
                ),
                const SizedBox(width: AppSizes.sm),
                _StatChip(
                  label: 'Activos',
                  count: active.length,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSizes.sm),
                _StatChip(
                  label: 'Hoy',
                  count: orders
                      .where(
                        (o) =>
                            o.createdAt.day == DateTime.now().day &&
                            o.createdAt.month == DateTime.now().month,
                      )
                      .length,
                  color: AppColors.success,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
            if (pending.isNotEmpty) ...[
              _SectionLabel('Nuevos pedidos (${pending.length})'),
              ...pending.map((o) => _OrderManageCard(order: o)),
              const SizedBox(height: AppSizes.md),
            ],
            if (active.isNotEmpty) ...[
              _SectionLabel('En proceso (${active.length})'),
              ...active.map((o) => _OrderManageCard(order: o)),
              const SizedBox(height: AppSizes.md),
            ],
            if (completed.isNotEmpty) ...[
              _SectionLabel('Completados'),
              ...completed.take(10).map((o) => _OrderManageCard(order: o)),
            ],
          ],
        );
      },
    );
  }
}

// ============ PRODUCTOS ============
class _ItemsTab extends ConsumerWidget {
  final StoreModel store;
  const _ItemsTab({required this.store});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(storeAllItemsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'store_item_fab',
        onPressed: () => _showItemDialog(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
      body: itemsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.restaurant_menu,
              title: 'Sin productos',
              subtitle: 'Agrega tu primer producto con el botón +',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: items.length,
            itemBuilder: (_, i) => _ItemManageCard(
              item: items[i],
              onEdit: () => _showItemDialog(context, ref, items[i]),
              onToggle: () => ref
                  .read(storesRepositoryProvider)
                  .updateStoreItem(store.id, items[i].id, {
                    'available': !items[i].available,
                  }),
              onDelete: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Eliminar producto'),
                    content: Text('¿Eliminar "${items[i].name}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                        child: const Text('Eliminar'),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  await ref
                      .read(storesRepositoryProvider)
                      .deleteStoreItem(store.id, items[i].id);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _showItemDialog(
    BuildContext context,
    WidgetRef ref,
    StoreItemModel? existing,
  ) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final descController = TextEditingController(
      text: existing?.description ?? '',
    );
    final priceController = TextEditingController(
      text: existing?.price.toString() ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Nuevo producto' : 'Editar producto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Precio (COP)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(existing == null ? 'Crear' : 'Guardar'),
          ),
        ],
      ),
    );

    if (result != true || !context.mounted) return;

    final price = int.tryParse(priceController.text.trim()) ?? 0;
    final data = {
      'name': nameController.text.trim(),
      'description': descController.text.trim(),
      'price': price,
    };

    final repo = ref.read(storesRepositoryProvider);
    if (existing == null) {
      await repo.addStoreItem(
        store.id,
        StoreItemModel(
          id: '',
          storeId: store.id,
          name: nameController.text.trim(),
          description: descController.text.trim(),
          price: price,
        ),
      );
      if (context.mounted) context.showSuccessSnackBar('Producto creado');
    } else {
      await repo.updateStoreItem(store.id, existing.id, data);
      if (context.mounted) context.showSuccessSnackBar('Producto actualizado');
    }
  }
}

class _ItemManageCard extends StatelessWidget {
  final StoreItemModel item;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ItemManageCard({
    required this.item,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Padding(
        padding: AppSizes.paddingCard,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.available
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.border,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(
                Icons.fastfood,
                color: item.available ? AppColors.primary : AppColors.textHint,
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: item.available
                          ? null
                          : TextDecoration.lineThrough,
                      color: item.available ? null : AppColors.textHint,
                    ),
                  ),
                  if (item.description != null && item.description!.isNotEmpty)
                    Text(
                      item.description!,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    item.formattedPrice,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') onEdit();
                if (v == 'toggle') onToggle();
                if (v == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Editar')),
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(item.available ? 'Ocultar' : 'Activar'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Eliminar', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============ INFORMACIÓN ============
class _InfoTab extends ConsumerWidget {
  final StoreModel store;
  const _InfoTab({required this.store});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        _InfoRow(label: 'Nombre', value: store.name),
        _InfoRow(label: 'Descripción', value: store.description),
        _InfoRow(label: 'Tiempo de entrega', value: store.deliveryTime),
        _InfoRow(label: 'Pedido mínimo', value: store.formattedMinOrder),
        _InfoRow(
          label: 'Estado',
          value: store.active ? 'Activa' : 'Inactiva',
          valueColor: store.active ? AppColors.success : AppColors.error,
        ),
        _InfoRow(
          label: 'Calificación',
          value: '${store.rating.toStringAsFixed(1)} ⭐',
        ),
        _InfoRow(label: 'Pedidos completados', value: '${store.orderCount}'),
        const SizedBox(height: AppSizes.xl),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => _showEditDialog(context, ref),
            icon: const Icon(Icons.edit),
            label: const Text('Editar información'),
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => ref
                .read(storesRepositoryProvider)
                .updateStore(store.id, {'active': !store.active}),
            icon: Icon(store.active ? Icons.pause : Icons.play_arrow),
            label: Text(store.active ? 'Pausar tienda' : 'Reactivar tienda'),
            style: OutlinedButton.styleFrom(
              foregroundColor: store.active
                  ? AppColors.warning
                  : AppColors.success,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController(text: store.name);
    final descController = TextEditingController(text: store.description);
    final deliveryController = TextEditingController(text: store.deliveryTime);
    final minOrderController = TextEditingController(
      text: store.minOrder.toString(),
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar tienda'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: deliveryController,
                decoration: const InputDecoration(labelText: 'Tiempo entrega'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: minOrderController,
                decoration: const InputDecoration(labelText: 'Pedido mínimo'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result != true || !context.mounted) return;
    await ref.read(storesRepositoryProvider).updateStore(store.id, {
      'name': nameController.text.trim(),
      'description': descController.text.trim(),
      'deliveryTime': deliveryController.text.trim(),
      'minOrder': int.tryParse(minOrderController.text.trim()) ?? store.minOrder,
    });
    if (context.mounted) context.showSuccessSnackBar('Actualizado');
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ WIDGETS ORIGINALES ============
class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _OrderManageCard extends ConsumerWidget {
  final OrderModel order;

  const _OrderManageCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Padding(
        padding: AppSizes.paddingCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(order.status.icon, size: 18, color: order.status.color),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    '#${order.id.substring(0, 4).toUpperCase()} — ${order.buyerName}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: order.status.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Text(
                    order.status.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: order.status.color,
                    ),
                  ),
                ),
              ],
            ),
            if (order.buyerApartment != null &&
                order.buyerApartment!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  order.buyerApartment!,
                  style: AppTextStyles.caption,
                ),
              ),
            const SizedBox(height: AppSizes.xs),
            Text(
              order.itemsSummary,
              style: AppTextStyles.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatCOP(order.total),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
                Text(order.createdAt.timeAgoText, style: AppTextStyles.caption),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            if (order.status == OrderStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => ref
                          .read(storesRepositoryProvider)
                          .updateOrderStatus(order.id, OrderStatus.cancelled),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      child: const Text('Rechazar'),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => ref
                          .read(storesRepositoryProvider)
                          .updateOrderStatus(order.id, OrderStatus.confirmed),
                      child: const Text('Confirmar'),
                    ),
                  ),
                ],
              ),
            if (order.status == OrderStatus.confirmed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => ref
                      .read(storesRepositoryProvider)
                      .updateOrderStatus(order.id, OrderStatus.inTransit),
                  icon: const Icon(Icons.delivery_dining, size: 18),
                  label: const Text('Marcar en camino'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ),
            if (order.status == OrderStatus.inTransit)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => ref
                      .read(storesRepositoryProvider)
                      .updateOrderStatus(order.id, OrderStatus.delivered),
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: const Text('Marcar entregado'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
