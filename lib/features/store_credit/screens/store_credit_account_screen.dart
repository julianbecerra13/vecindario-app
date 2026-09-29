import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/features/store_credit/models/store_credit_model.dart';
import 'package:vecindario_app/features/store_credit/providers/store_credit_provider.dart';
import 'package:vecindario_app/features/stores/models/order_model.dart';
import 'package:vecindario_app/features/stores/providers/stores_provider.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';

class StoreCreditAccountScreen extends ConsumerWidget {
  const StoreCreditAccountScreen({
    super.key,
    required this.storeId,
    required this.residentUid,
    this.residentName,
  });

  final String storeId;
  final String residentUid;
  final String? residentName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(storeCreditRepositoryProvider);
    final currentUid = ref.watch(currentUserProvider).value?.id;
    return FutureBuilder(
      future: ref.watch(storesRepositoryProvider).getStore(storeId),
      builder: (context, storeSnapshot) {
        final store = storeSnapshot.data;
        if (!storeSnapshot.hasData) {
          return const Scaffold(body: LoadingIndicator());
        }
        final isOwner = store?.ownerUid == currentUid;
        final isResident = residentUid == currentUid;
        if (store == null || (!isOwner && !isResident)) {
          return Scaffold(
            appBar: AppBar(title: const Text('Cuenta de fiado')),
            body: const Center(child: Text('No tienes acceso a esta cuenta.')),
          );
        }
        return StreamBuilder<StoreCreditAccount?>(
          stream: repository.watchAccount(storeId, residentUid),
          builder: (context, accountSnapshot) {
            if (accountSnapshot.hasError) {
              return Scaffold(
                appBar: AppBar(title: const Text('Cuenta de fiado')),
                body: Center(
                  child: Text(
                    'No se pudo abrir la cuenta: ${accountSnapshot.error}',
                  ),
                ),
              );
            }
            if (!accountSnapshot.hasData) {
              return const Scaffold(body: LoadingIndicator());
            }
            final account = accountSnapshot.data;
            if (account == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Cuenta de fiado')),
                body: const Center(
                  child: Text(
                    'Esta tienda no ha creado una cuenta de fiado para ti.',
                  ),
                ),
              );
            }
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  isOwner ? account.residentName : 'Mi fiado · ${store.name}',
                ),
              ),
              body: ListView(
                padding: const EdgeInsets.all(AppSizes.md),
                children: [
                  _AccountSummary(account: account),
                  const SizedBox(height: AppSizes.lg),
                  if (isOwner) ...[
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: account.active
                                ? () => _addMovement(
                                    context,
                                    ref,
                                    account,
                                    'charge',
                                  )
                                : null,
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('Registrar compra'),
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: account.active && account.balance > 0
                                ? () => _addMovement(
                                    context,
                                    ref,
                                    account,
                                    'payment',
                                  )
                                : null,
                            icon: const Icon(Icons.payments_outlined),
                            label: const Text('Registrar abono'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.lg),
                  ],
                  Text(
                    'Movimientos',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  StreamBuilder<List<StoreCreditMovement>>(
                    stream: repository.watchMovements(storeId, residentUid),
                    builder: (context, movementSnapshot) {
                      if (!movementSnapshot.hasData) {
                        return const LoadingIndicator();
                      }
                      final movements = movementSnapshot.data!;
                      if (movements.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSizes.xl),
                          child: Center(
                            child: Text('Sin movimientos todavía.'),
                          ),
                        );
                      }
                      return Column(
                        children: movements
                            .map(
                              (movement) => _MovementTile(movement: movement),
                            )
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addMovement(
    BuildContext context,
    WidgetRef ref,
    StoreCreditAccount account,
    String type,
  ) async {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          type == 'charge' ? 'Registrar compra fiada' : 'Registrar abono',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Valor',
                prefixText: r'$ ',
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: noteController,
              maxLength: 120,
              decoration: InputDecoration(
                labelText: type == 'charge'
                    ? 'Detalle de la compra'
                    : 'Nota del abono',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    final amount =
        int.tryParse(amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
        0;
    final note = noteController.text.trim();
    amountController.dispose();
    noteController.dispose();
    if (accepted != true) return;
    if (amount <= 0 || note.isEmpty) {
      if (context.mounted) {
        context.showErrorSnackBar('Ingresa un valor y una descripción.');
      }
      return;
    }
    try {
      await ref
          .read(storeCreditRepositoryProvider)
          .addMovement(
            storeId: storeId,
            residentUid: residentUid,
            type: type,
            amount: amount,
            note: note,
          );
      if (context.mounted) {
        context.showSuccessSnackBar(
          type == 'charge' ? 'Compra registrada.' : 'Abono registrado.',
        );
      }
    } on StateError catch (error) {
      if (context.mounted) context.showErrorSnackBar(error.message.toString());
    } catch (_) {
      if (context.mounted) {
        context.showErrorSnackBar('No fue posible registrar el movimiento.');
      }
    }
  }
}

class _AccountSummary extends StatelessWidget {
  const _AccountSummary({required this.account});
  final StoreCreditAccount account;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Código ${account.code}',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            const Text(
              'Saldo pendiente',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              formatCOP(account.balance),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cupo ${formatCOP(account.limit)}',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'Disponible ${formatCOP(account.available)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
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

class _MovementTile extends StatelessWidget {
  const _MovementTile({required this.movement});
  final StoreCreditMovement movement;

  @override
  Widget build(BuildContext context) {
    final charge = movement.type == 'charge';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: charge ? AppColors.errorLight : AppColors.successLight,
        child: Icon(
          charge ? Icons.shopping_bag_outlined : Icons.south_west,
          color: charge ? AppColors.error : AppColors.success,
        ),
      ),
      title: Text(movement.note),
      subtitle: Text(
        '${movement.createdAt.day}/${movement.createdAt.month}/${movement.createdAt.year}',
      ),
      trailing: Text(
        '${charge ? '+' : '-'}${formatCOP(movement.amount)}',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: charge ? AppColors.error : AppColors.success,
        ),
      ),
    );
  }
}
