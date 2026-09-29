import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/config/backend_features.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/extensions/datetime_extensions.dart';
import 'package:vecindario_app/core/extensions/l10n_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/stores/models/order_model.dart';
import 'package:vecindario_app/features/stores/models/store_item_model.dart';
import 'package:vecindario_app/features/stores/models/store_model.dart';
import 'package:vecindario_app/features/stores/providers/stores_provider.dart';
import 'package:vecindario_app/features/stores/services/catalog_import_service.dart';
import 'package:vecindario_app/features/store_credit/models/store_credit_model.dart';
import 'package:vecindario_app/features/store_credit/providers/store_credit_provider.dart';
import 'package:vecindario_app/shared/models/user_model.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/widgets/empty_state.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';
import 'package:vecindario_app/shared/widgets/image_picker_sheet.dart';
import 'package:vecindario_app/shared/widgets/media_image.dart';

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
        appBar: AppBar(title: Text(context.l10n.storePanelTitle)),
        body: Center(child: Text(context.l10n.errorWithDetail('$e'))),
      ),
      data: (store) {
        if (store == null) return const _NoStoreView();
        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              title: Text(store.name),
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.receipt_long), text: 'Pedidos'),
                  Tab(icon: Icon(Icons.restaurant_menu), text: 'Productos'),
                  Tab(icon: Icon(Icons.account_balance_wallet), text: 'Fiados'),
                  Tab(icon: Icon(Icons.info_outline), text: 'Información'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _OrdersTab(),
                _ItemsTab(store: store),
                _CreditsTab(store: store),
                _InfoTab(store: store),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CreditsTab extends ConsumerWidget {
  const _CreditsTab({required this.store});

  final StoreModel store;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(storeCreditRepositoryProvider);
    return StreamBuilder<List<StoreCreditAccount>>(
      stream: repository.watchAccounts(store.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('No se pudieron cargar las cuentas: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData) return const LoadingIndicator();
        final accounts = snapshot.data!;
        return Scaffold(
          body: accounts.isEmpty
              ? const EmptyState(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Aún no hay cuentas de fiado',
                  subtitle:
                      'Crea una cuenta privada para asignar código y cupo a un residente.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSizes.md),
                  itemCount: accounts.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSizes.sm),
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            account.residentName.isEmpty
                                ? '?'
                                : account.residentName[0].toUpperCase(),
                          ),
                        ),
                        title: Text(account.residentName),
                        subtitle: Text(
                          'Código ${account.code} · Saldo ${formatCOP(account.balance)}\nDisponible ${formatCOP(account.available)}',
                        ),
                        isThreeLine: true,
                        trailing: Icon(
                          account.active ? Icons.chevron_right : Icons.block,
                          color: account.active ? null : AppColors.error,
                        ),
                        onTap: () => context.push(
                          '/store-credit/${store.id}/${account.residentUid}',
                          extra: account.residentName,
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _createCreditAccount(context, ref),
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Nueva cuenta'),
          ),
        );
      },
    );
  }

  Future<void> _createCreditAccount(BuildContext context, WidgetRef ref) async {
    final membersSnapshot = await ref
        .read(firestoreProvider)
        .collection('users')
        .where('communityId', isEqualTo: store.communityId)
        .where('verified', isEqualTo: true)
        .get();
    final members =
        membersSnapshot.docs
            .where((doc) => doc.id != store.ownerUid)
            .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
            .toList()
          ..sort((a, b) => a.displayName.compareTo(b.displayName));
    if (!context.mounted) return;
    if (members.isEmpty) {
      context.showErrorSnackBar('No hay residentes verificados disponibles.');
      return;
    }
    UserModel selected = members.first;
    final code = TextEditingController();
    final limit = TextEditingController();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nueva cuenta de fiado'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<UserModel>(
                  initialValue: selected,
                  decoration: const InputDecoration(labelText: 'Residente'),
                  items: members
                      .map(
                        (member) => DropdownMenuItem(
                          value: member,
                          child: Text(
                            '${member.displayName} · ${member.unitInfo}',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      value == null ? null : setState(() => selected = value),
                ),
                const SizedBox(height: AppSizes.md),
                TextField(
                  controller: code,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 12,
                  decoration: const InputDecoration(
                    labelText: 'Código personalizado',
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                TextField(
                  controller: limit,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cupo máximo',
                    prefixText: r'$ ',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
    final parsedLimit =
        int.tryParse(limit.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final parsedCode = code.text.trim();
    code.dispose();
    limit.dispose();
    if (accepted != true) return;
    if (parsedCode.length < 4 || parsedLimit <= 0) {
      if (context.mounted) {
        context.showErrorSnackBar(
          'Ingresa un código de mínimo 4 caracteres y un cupo válido.',
        );
      }
      return;
    }
    try {
      await ref
          .read(storeCreditRepositoryProvider)
          .createAccount(
            storeId: store.id,
            residentUid: selected.id,
            residentName: selected.displayName,
            code: parsedCode,
            limit: parsedLimit,
          );
      if (context.mounted) {
        context.showSuccessSnackBar('Cuenta de fiado creada.');
      }
    } catch (_) {
      if (context.mounted) {
        context.showErrorSnackBar('No fue posible crear la cuenta.');
      }
    }
  }
}

// ============ NO STORE VIEW ============
class _NoStoreView extends ConsumerWidget {
  const _NoStoreView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.storePanelTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.storefront, size: 80, color: context.colors.textHint),
              const SizedBox(height: AppSizes.md),
              const Text(
                'Aún no tienes tienda',
                style: AppTextStyles.heading3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                context.l10n.storeCreatePrompt,
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
                  label: Text(context.l10n.storeCreateMyStoreButton),
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
    final phoneController = TextEditingController();
    final paymentController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.storeCreateDialogTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: context.l10n.storeNameLabel,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: context.l10n.serviceDescriptionLabel,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: deliveryController,
                decoration: InputDecoration(
                  labelText: context.l10n.storeDeliveryTimeLabel,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: minOrderController,
                decoration: InputDecoration(
                  labelText: context.l10n.storeMinOrderLabel,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'WhatsApp o teléfono',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: paymentController,
                decoration: const InputDecoration(
                  labelText: 'Datos para transferencia',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.create),
          ),
        ],
      ),
    );

    if (result != true || !context.mounted) return;
    final user = ref.read(currentUserProvider).value;
    final communityId = ref.read(currentCommunityIdProvider);
    if (user == null || communityId == null) {
      context.showErrorSnackBar(context.l10n.storeNoCommunityAssigned);
      return;
    }

    await ref
        .read(storesRepositoryProvider)
        .createStore(
          StoreModel(
            id: '',
            ownerUid: user.id,
            communityId: communityId,
            name: nameController.text.trim(),
            description: descController.text.trim(),
            deliveryTime: deliveryController.text.trim(),
            minOrder: int.tryParse(minOrderController.text.trim()) ?? 10000,
            contactPhone: phoneController.text.trim().isEmpty
                ? null
                : phoneController.text.trim(),
            paymentInstructions: paymentController.text.trim().isEmpty
                ? null
                : paymentController.text.trim(),
            createdAt: DateTime.now(),
          ),
        );
    if (context.mounted) {
      context.showSuccessSnackBar(context.l10n.storeCreated);
    }
  }
}

// ============ PEDIDOS ============
class _OrdersTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(storeOrdersProvider);

    return ordersAsync.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => Center(child: Text(context.l10n.errorWithDetail('$e'))),
      data: (orders) {
        if (orders.isEmpty) {
          return EmptyState(
            icon: Icons.inbox_outlined,
            title: context.l10n.storePanelNoOrdersTitle,
            subtitle: context.l10n.storePanelNoOrdersSubtitle,
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
                  label: context.l10n.storePendingLabel,
                  count: pending.length,
                  color: AppColors.warning,
                ),
                const SizedBox(width: AppSizes.sm),
                _StatChip(
                  label: context.l10n.storeActiveLabel,
                  count: active.length,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSizes.sm),
                _StatChip(
                  label: context.l10n.storeTodayLabel,
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
              _SectionLabel(context.l10n.storeNewOrdersCount(pending.length)),
              ...pending.map((o) => _OrderManageCard(order: o)),
              const SizedBox(height: AppSizes.md),
            ],
            if (active.isNotEmpty) ...[
              _SectionLabel(context.l10n.storeInProgressCount(active.length)),
              ...active.map((o) => _OrderManageCard(order: o)),
              const SizedBox(height: AppSizes.md),
            ],
            if (completed.isNotEmpty) ...[
              _SectionLabel(context.l10n.storeCompletedLabel),
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'store_template_fab',
            tooltip: 'Descargar plantilla de catálogo',
            onPressed: () => _shareCatalogTemplate(context),
            child: const Icon(Icons.download_outlined),
          ),
          const SizedBox(height: AppSizes.sm),
          FloatingActionButton.small(
            heroTag: 'store_import_fab',
            tooltip: 'Importar catálogo desde Excel',
            onPressed: () => _importCatalog(context, ref),
            child: const Icon(Icons.upload_file),
          ),
          const SizedBox(height: AppSizes.sm),
          FloatingActionButton.extended(
            heroTag: 'store_item_fab',
            onPressed: () => _showItemDialog(context, ref, null),
            icon: const Icon(Icons.add),
            label: Text(context.l10n.storeNewItemFab),
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) =>
            Center(child: Text(context.l10n.errorWithDetail('$e'))),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.restaurant_menu,
              title: context.l10n.storeNoItemsTitle,
              subtitle: context.l10n.storeNoItemsSubtitle,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: items.length + 1,
            itemBuilder: (_, i) {
              if (i == 0) {
                return Card(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  margin: const EdgeInsets.only(bottom: AppSizes.md),
                  child: Padding(
                    padding: AppSizes.paddingCard,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tu tienda es un catálogo',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Publica todos tus productos aquí. Puedes agregar uno, incluir tallas o colores, o importar cientos desde Excel.',
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Wrap(
                          spacing: AppSizes.sm,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _shareCatalogTemplate(context),
                              icon: const Icon(Icons.download_outlined),
                              label: const Text('Plantilla Excel'),
                            ),
                            FilledButton.icon(
                              onPressed: () => _importCatalog(context, ref),
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Importar catálogo'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
              final item = items[i - 1];
              return _ItemManageCard(
                item: item,
                onEdit: () => _showItemDialog(context, ref, item),
                onToggle: () =>
                    ref.read(storesRepositoryProvider).updateStoreItem(
                      store.id,
                      item.id,
                      {'available': !item.available},
                    ),
                onDelete: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(context.l10n.storeDeleteProductTitle),
                      content: Text(
                        context.l10n.storeDeleteProductConfirm(item.name),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(context.l10n.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                          ),
                          child: Text(context.l10n.delete),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await ref
                        .read(storesRepositoryProvider)
                        .deleteStoreItem(store.id, item.id);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _shareCatalogTemplate(BuildContext context) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/plantilla_catalogo_vecindario.xlsx');
      await file.writeAsBytes(
        CatalogImportService.createTemplate(),
        flush: true,
      );
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Plantilla para importar el catálogo de la tienda en Vecindario.',
      );
    } catch (_) {
      if (context.mounted) {
        context.showErrorSnackBar('No fue posible generar la plantilla.');
      }
    }
  }

  Future<void> _importCatalog(BuildContext context, WidgetRef ref) async {
    final selection = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );
    final bytes = selection?.files.single.bytes;
    if (bytes == null || !context.mounted) return;
    try {
      final result = CatalogImportService.parseXlsx(bytes, store.id);
      if (result.items.isEmpty) {
        context.showErrorSnackBar('El archivo no contiene productos válidos.');
        return;
      }
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Importar catálogo'),
          content: Text(
            'Se agregarán ${result.items.length} productos.'
            '${result.skippedRows > 0 ? ' Se omitirán ${result.skippedRows} filas incompletas.' : ''}\n\n'
            'Columnas admitidas: Nombre, Precio, Descripcion, Categoria y Disponible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Importar'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await ref
          .read(storesRepositoryProvider)
          .importStoreItems(store.id, result.items);
      if (context.mounted) {
        context.showSuccessSnackBar(
          '${result.items.length} productos importados.',
        );
      }
    } on FormatException catch (error) {
      if (context.mounted) context.showErrorSnackBar(error.message);
    } catch (_) {
      if (context.mounted) {
        context.showErrorSnackBar('No fue posible leer o importar el Excel.');
      }
    }
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
    final categoryController = TextEditingController(
      text: existing?.category ?? '',
    );
    final variantsController = TextEditingController(
      text: existing?.variants.join(', ') ?? '',
    );
    File? selectedImage;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            existing == null
                ? context.l10n.storeNewProductTitle
                : context.l10n.storeEditProductTitle,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () async {
                    if (!kMediaUploadsEnabled) {
                      context.showSnackBar(kMediaUploadsUnavailableMessage);
                      return;
                    }
                    final file = await showImagePickerSheet(ctx);
                    if (file != null && ctx.mounted) {
                      setDialogState(() => selectedImage = file);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 130,
                    decoration: BoxDecoration(
                      color: context.colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                      image: selectedImage != null
                          ? DecorationImage(
                              image: FileImage(selectedImage!),
                              fit: BoxFit.cover,
                            )
                          : existing?.imageURL != null
                          ? DecorationImage(
                              image: mediaImageProvider(existing!.imageURL!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: selectedImage == null && existing?.imageURL == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 34),
                              SizedBox(height: 6),
                              Text(
                                kMediaUploadsEnabled
                                    ? 'Agregar fotografía'
                                    : 'Fotografías próximamente',
                              ),
                            ],
                          )
                        : const Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: CircleAvatar(child: Icon(Icons.edit)),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: context.l10n.storeItemNameLabel,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: context.l10n.serviceDescriptionLabel,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: context.l10n.storeItemPriceLabel,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    hintText: 'Ej. Pijamas, Mujer, Niños',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: variantsController,
                  decoration: const InputDecoration(
                    labelText: 'Opciones o variantes',
                    hintText: 'Ej. Talla S - Azul, Talla M - Roja',
                    helperText:
                        'Sepáralas por comas. El cliente elegirá al comprar.',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                existing == null ? context.l10n.create : context.l10n.save,
              ),
            ),
          ],
        ),
      ),
    );

    if (result != true || !context.mounted) return;

    final price = int.tryParse(priceController.text.trim()) ?? 0;
    final data = {
      'name': nameController.text.trim(),
      'description': descController.text.trim(),
      'price': price,
      'category': categoryController.text.trim(),
      'variants': _parseVariants(variantsController.text),
    };

    final repo = ref.read(storesRepositoryProvider);
    if (existing == null) {
      final itemId = await repo.addStoreItem(
        store.id,
        StoreItemModel(
          id: '',
          storeId: store.id,
          name: nameController.text.trim(),
          description: descController.text.trim(),
          price: price,
          category: categoryController.text.trim(),
          variants: _parseVariants(variantsController.text),
        ),
      );
      if (selectedImage != null) {
        final imageURL = await repo.uploadStoreItemImage(
          store.id,
          itemId,
          selectedImage!,
        );
        await repo.updateStoreItem(store.id, itemId, {'imageURL': imageURL});
      }
      if (context.mounted) {
        context.showSuccessSnackBar(context.l10n.storeProductCreated);
      }
    } else {
      if (selectedImage != null) {
        data['imageURL'] = await repo.uploadStoreItemImage(
          store.id,
          existing.id,
          selectedImage!,
        );
      }
      await repo.updateStoreItem(store.id, existing.id, data);
      if (context.mounted) {
        context.showSuccessSnackBar(context.l10n.storeProductUpdated);
      }
    }
  }

  List<String> _parseVariants(String value) => value
      .split(RegExp(r'[,;]'))
      .map((variant) => variant.trim())
      .where((variant) => variant.isNotEmpty)
      .toSet()
      .toList();
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
                    : context.colors.border,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                image: item.imageURL?.isNotEmpty == true
                    ? DecorationImage(
                        image: mediaImageProvider(item.imageURL!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: item.imageURL?.isNotEmpty == true
                  ? null
                  : Icon(
                      Icons.fastfood,
                      color: item.available
                          ? AppColors.primary
                          : context.colors.textHint,
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
                      color: item.available ? null : context.colors.textHint,
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
                    style: const TextStyle(
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
                PopupMenuItem(value: 'edit', child: Text(context.l10n.edit)),
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(
                    item.available
                        ? context.l10n.storeHideLabel
                        : context.l10n.storeActivateLabel,
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    context.l10n.delete,
                    style: const TextStyle(color: AppColors.error),
                  ),
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
        _InfoRow(label: context.l10n.storeItemNameLabel, value: store.name),
        _InfoRow(
          label: context.l10n.serviceDescriptionLabel,
          value: store.description,
        ),
        _InfoRow(
          label: context.l10n.storeDeliveryTimeLabel,
          value: store.deliveryTime,
        ),
        _InfoRow(
          label: context.l10n.storeMinOrderLabel,
          value: store.formattedMinOrder,
        ),
        _InfoRow(
          label: context.l10n.storeStatusLabel,
          value: store.active
              ? context.l10n.storeActiveStatus
              : context.l10n.storeInactiveStatus,
          valueColor: store.active ? AppColors.success : AppColors.error,
        ),
        _InfoRow(
          label: context.l10n.storeRatingLabel,
          value: '${store.rating.toStringAsFixed(1)} ⭐',
        ),
        _InfoRow(
          label: context.l10n.storeCompletedOrdersLabel,
          value: '${store.orderCount}',
        ),
        _InfoRow(
          label: 'Contacto',
          value: store.contactPhone?.isNotEmpty == true
              ? store.contactPhone!
              : 'Sin configurar',
        ),
        _InfoRow(
          label: 'Transferencias',
          value: store.paymentInstructions?.isNotEmpty == true
              ? store.paymentInstructions!
              : 'Sin configurar',
        ),
        const SizedBox(height: AppSizes.xl),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => _showEditDialog(context, ref),
            icon: const Icon(Icons.edit),
            label: Text(context.l10n.storeEditInfoButton),
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => ref.read(storesRepositoryProvider).updateStore(
              store.id,
              {'active': !store.active},
            ),
            icon: Icon(store.active ? Icons.pause : Icons.play_arrow),
            label: Text(
              store.active
                  ? context.l10n.storePauseStoreButton
                  : context.l10n.storeReactivateStoreButton,
            ),
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
    final phoneController = TextEditingController(
      text: store.contactPhone ?? '',
    );
    final paymentController = TextEditingController(
      text: store.paymentInstructions ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.storeEditDialogTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: context.l10n.storeItemNameLabel,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: context.l10n.serviceDescriptionLabel,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: deliveryController,
                decoration: InputDecoration(
                  labelText: context.l10n.storeDeliveryTimeLabel,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: minOrderController,
                decoration: InputDecoration(
                  labelText: context.l10n.storeMinOrderLabel,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'WhatsApp o teléfono',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: paymentController,
                decoration: const InputDecoration(
                  labelText: 'Datos para transferencia',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );

    if (result != true || !context.mounted) return;
    await ref.read(storesRepositoryProvider).updateStore(store.id, {
      'name': nameController.text.trim(),
      'description': descController.text.trim(),
      'deliveryTime': deliveryController.text.trim(),
      'minOrder':
          int.tryParse(minOrderController.text.trim()) ?? store.minOrder,
      'contactPhone': phoneController.text.trim(),
      'paymentInstructions': paymentController.text.trim(),
    });
    if (context.mounted) {
      context.showSuccessSnackBar(context.l10n.storeUpdated);
    }
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
              style: TextStyle(fontSize: 10, color: context.colors.textHint),
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
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: context.colors.textSecondary,
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
                  style: const TextStyle(
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
                      child: Text(context.l10n.storeRejectButton),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => ref
                          .read(storesRepositoryProvider)
                          .updateOrderStatus(order.id, OrderStatus.confirmed),
                      child: Text(context.l10n.confirm),
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
                  label: Text(context.l10n.storeMarkOnWayButton),
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
                  label: Text(context.l10n.storeMarkDeliveredButton),
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
